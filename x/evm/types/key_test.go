package types

import (
	"testing"
)

func TestLogsKey(t *testing.T) {
	t.Logf("LogsKey(nil): %s len: %v logsPrefix: %s len: %v \n", LogsKey(nil), len(LogsKey(nil)), logsPrefix, len(logsPrefix))
}
