package evm

import (
	"math/big"

	abci "github.com/tendermint/tendermint/abci/types"

	sdk "github.com/cosmos/cosmos-sdk/types"

	ethtypes "github.com/ethereum/go-ethereum/core/types"
)

// BeginBlock sets the Bloom and Hash mappings and resets the Bloom filter and
// the transaction count to 0.
func BeginBlock(k Keeper, ctx sdk.Context, req abci.RequestBeginBlock) {
	if req.Header.LastBlockId.GetHash() == nil || req.Header.GetHeight() < 1 {
		return
	}

	// if k.CommitStateDB.GetLogSize() == 0 {
	// 	alllogs := k.AllTransactionLogs(ctx)
	//
	// 	getAllLogsAsJson, err := json.Marshal(alllogs)
	// 	if err != nil {
	// 		ctx.Logger().Error("getAllLogsAsJson", "err", err.Error())
	// 	}
	//
	// 	ctx.Logger().Info("getAllLogsAsJson", "all logs len", len(alllogs), "json output", getAllLogsAsJson)
	//
	// 	k.CommitStateDB.SetLogSize(uint(len(alllogs)))
	// }
	k.CommitStateDB.SetLogSize(0)

	// Consider removing this when using evm as module without web3 API
	bloom := ethtypes.BytesToBloom(k.Bloom.Bytes())
	k.SetBlockBloomMapping(ctx, bloom, req.Header.GetHeight()-1)
	k.SetBlockHashMapping(ctx, req.Header.LastBlockId.GetHash(), req.Header.GetHeight()-1)
	k.Bloom = big.NewInt(0)
	k.TxCount = 0
}

// EndBlock updates the accounts and commits states objects to the KV Store
func EndBlock(k Keeper, ctx sdk.Context, _ abci.RequestEndBlock) []abci.ValidatorUpdate {
	snapshot := k.CommitStateDB.WithContext(ctx).Snapshot()
	defer func() {
		if r := recover(); r != nil {
			k.RevertToSnapshot(ctx, snapshot)
		}
	}()

	// Gas costs are handled within msg handler so costs should be ignored
	ctx = ctx.WithBlockGasMeter(sdk.NewInfiniteGasMeter())

	// Update account balances before committing other parts of state
	k.CommitStateDB.UpdateAccounts()

	// Commit state objects to KV store
	_, err := k.CommitStateDB.WithContext(ctx).Commit(true)
	if err != nil {
		panic(err)
	}

	// Clear accounts cache after account data has been committed
	k.CommitStateDB.ClearStateObjects()

	return []abci.ValidatorUpdate{}
}
