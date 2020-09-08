package evm

import (
	"encoding/json"
	"math/big"

	"github.com/ethereum/go-ethereum/common"

	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
	emint "github.com/cosmos/ethermint/types"
	"github.com/cosmos/ethermint/x/evm/types"

	proto "github.com/gogo/protobuf/proto"
	tmtypes "github.com/tendermint/tendermint/types"
)

// NewHandler returns a handler for Ethermint type messages.
func NewHandler(k Keeper) sdk.Handler {
	return func(ctx sdk.Context, msg sdk.Msg) (*sdk.Result, error) {
		ctx = ctx.WithEventManager(sdk.NewEventManager())
		switch msg := msg.(type) {
		case types.MsgEthereumTx:
			return handleMsgEthereumTx(ctx, k, msg)
		case types.MsgEthermint:
			return handleMsgEthermint(ctx, k, msg)
		default:
			return nil, sdkerrors.Wrapf(sdkerrors.ErrUnknownRequest, "unrecognized %s message type: %T", ModuleName, msg)
		}
	}
}

// handleMsgEthereumTx handles an Ethereum specific tx
func handleMsgEthereumTx(ctx sdk.Context, k Keeper, msg types.MsgEthereumTx) (*sdk.Result, error) {
	// parse the chainID from a string to a base-10 integer
	intChainID, ok := new(big.Int).SetString(ctx.ChainID(), 10)
	if !ok {
		return nil, sdkerrors.Wrap(emint.ErrInvalidChainID, ctx.ChainID())
	}

	// Verify signature and retrieve sender address
	sender, err := msg.VerifySig(intChainID)

	if err != nil {
		return nil, err
	}

	txHash := tmtypes.Tx(ctx.TxBytes()).Hash()
	ethHash := common.BytesToHash(txHash)

	st := types.StateTransition{
		AccountNonce: msg.Data.AccountNonce,
		Price:        msg.Data.Price,
		GasLimit:     msg.Data.GasLimit,
		Recipient:    msg.Data.Recipient,
		Amount:       msg.Data.Amount,
		Payload:      msg.Data.Payload,
		Csdb:         k.CommitStateDB.WithContext(ctx),
		ChainID:      intChainID,
		TxHash:       &ethHash,
		Sender:       sender,
		Simulate:     ctx.IsCheckTx(),
	}

	snapshot := k.CommitStateDB.WithContext(ctx).Snapshot()
	defer func() {
		if r := recover(); r != nil {
			k.RevertToSnapshot(ctx, snapshot)
			panic(r)
		}
		if !st.Simulate {
			// Finalise state if not a simulated transaction
			// TODO: change to depend on config
			if err := st.Csdb.Finalise(true); err != nil {
				panic(err)
			}
		}
	}()

	// Prepare db for logs
	// TODO: block hash
	k.CommitStateDB.Prepare(ethHash, common.Hash{}, k.TxCount)
	k.TxCount++

	// TODO: move to keeper
	executionResult, err := st.TransitionDb(ctx)
	if err != nil {
		return nil, err
	}

	// update block bloom filter
	k.Bloom.Or(k.Bloom, executionResult.Bloom)

	// update transaction logs in KVStore
	// err = k.SetTransactionLogs(ctx, executionResult.Logs, txHash)
	// if err != nil {
	// 	return nil, err
	// }

	logsInputAsJson, err := json.Marshal(executionResult.Logs)
	if err != nil {
		ctx.Logger().Error("logsInputAsJson", "err", err.Error())
	}

	ctx.Logger().Info("logsInputAsJson", "json input", logsInputAsJson)

	// update transaction logs in KVStore
	err = k.SetTransactionLogs(ctx, executionResult.Logs, txHash)
	if err != nil {
		return nil, err
	}

	logs, err := k.GetTransactionLogs(ctx, txHash)
	if err != nil {
		return nil, err
	}

	getLogsAsJson, err := json.Marshal(logs)
	if err != nil {
		ctx.Logger().Error("getLogsAsJson", "err", err.Error())
	}

	ctx.Logger().Info("getLogsAsJson", "json output", getLogsAsJson)

	// log successful execution
	k.Logger(ctx).Info(executionResult.Result.Log)

	ctx.EventManager().EmitEvents(sdk.Events{
		sdk.NewEvent(
			types.EventTypeEthereumTx,
			sdk.NewAttribute(sdk.AttributeKeyAmount, msg.Data.Amount.String()),
		),
		sdk.NewEvent(
			sdk.EventTypeMessage,
			sdk.NewAttribute(sdk.AttributeKeyModule, types.AttributeValueCategory),
			sdk.NewAttribute(sdk.AttributeKeySender, sender.String()),
		),
	})

	if msg.Data.Recipient != nil {
		ctx.EventManager().EmitEvent(
			sdk.NewEvent(
				types.EventTypeEthereumTx,
				sdk.NewAttribute(types.AttributeKeyRecipient, msg.Data.Recipient.String()),
			),
		)
	}

	// set the events to the result
	executionResult.Result.Events = ctx.EventManager().Events().ToABCIEvents()

	ctx.Logger().Info("handleMsgEthereumTx", "result", proto.CompactTextString(executionResult.Result))

	return executionResult.Result, nil
}

// handleMsgEthermint handles an sdk.StdTx for an Ethereum state transition
func handleMsgEthermint(ctx sdk.Context, k Keeper, msg types.MsgEthermint) (*sdk.Result, error) {
	// parse the chainID from a string to a base-10 integer
	intChainID, ok := new(big.Int).SetString(ctx.ChainID(), 10)
	if !ok {
		return nil, sdkerrors.Wrap(emint.ErrInvalidChainID, ctx.ChainID())
	}

	txHash := tmtypes.Tx(ctx.TxBytes()).Hash()
	ethHash := common.BytesToHash(txHash)

	st := types.StateTransition{
		AccountNonce: msg.AccountNonce,
		Price:        msg.Price.BigInt(),
		GasLimit:     msg.GasLimit,
		Amount:       msg.Amount.BigInt(),
		Payload:      msg.Payload,
		Csdb:         k.CommitStateDB.WithContext(ctx),
		ChainID:      intChainID,
		TxHash:       &ethHash,
		Sender:       common.BytesToAddress(msg.From.Bytes()),
		Simulate:     ctx.IsCheckTx(),
	}

	if st.Simulate {
		st.Csdb = st.Csdb.Copy()
	}

	snapshot := k.CommitStateDB.WithContext(ctx).Snapshot()
	defer func() {
		if r := recover(); r != nil {
			k.RevertToSnapshot(ctx, snapshot)
			panic(r)
		}
		if !st.Simulate {
			// Finalise state if not a simulated transaction
			// TODO: change to depend on config
			if err := st.Csdb.Finalise(true); err != nil {
				panic(err)
			}
		}
	}()

	if msg.Recipient != nil {
		to := common.BytesToAddress(msg.Recipient.Bytes())
		st.Recipient = &to
	}

	// Prepare db for logs
	k.CommitStateDB.Prepare(ethHash, common.Hash{}, k.TxCount)
	k.TxCount++

	executionResult, err := st.TransitionDb(ctx)
	if err != nil {
		return nil, err
	}

	// update block bloom filter
	k.Bloom.Or(k.Bloom, executionResult.Bloom)

	logsInputAsJson, err := json.Marshal(executionResult.Logs)
	if err != nil {
		ctx.Logger().Error("logsInputAsJson", "err", err.Error())
	}

	ctx.Logger().Info("logsInputAsJson", "json input", logsInputAsJson)

	// update transaction logs in KVStore
	err = k.SetTransactionLogs(ctx, executionResult.Logs, txHash)
	if err != nil {
		return nil, err
	}

	logs, err := k.GetTransactionLogs(ctx, txHash)
	if err != nil {
		return nil, err
	}

	getLogsAsJson, err := json.Marshal(logs)
	if err != nil {
		ctx.Logger().Error("getLogsAsJson", "err", err.Error())
	}

	ctx.Logger().Info("getLogsAsJson", "json output", getLogsAsJson)

	// log successful execution
	k.Logger(ctx).Info(executionResult.Result.Log)

	ctx.EventManager().EmitEvents(sdk.Events{
		sdk.NewEvent(
			types.EventTypeEthermint,
			sdk.NewAttribute(sdk.AttributeKeyAmount, msg.Amount.String()),
		),
		sdk.NewEvent(
			sdk.EventTypeMessage,
			sdk.NewAttribute(sdk.AttributeKeyModule, types.AttributeValueCategory),
			sdk.NewAttribute(sdk.AttributeKeySender, msg.From.String()),
		),
	})

	if msg.Recipient != nil {
		ctx.EventManager().EmitEvent(
			sdk.NewEvent(
				types.EventTypeEthermint,
				sdk.NewAttribute(types.AttributeKeyRecipient, msg.Recipient.String()),
			),
		)
	}

	// set the events to the result
	executionResult.Result.Events = ctx.EventManager().Events().ToABCIEvents()

	ctx.Logger().Info("handleMsgEthermint", "result", proto.CompactTextString(executionResult.Result))

	return executionResult.Result, nil
}
