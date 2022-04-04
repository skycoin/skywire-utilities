package httputil

import (
	"time"

	"github.com/skycoin/skywire-utilities/pkg/buildinfo"
)

// HealthCheckResponse is struct of /health endpoint
type HealthCheckResponse struct {
	BuildInfo *buildinfo.Info `json:"build_info,omitempty"`
	StartedAt time.Time       `json:"started_at"`
}
