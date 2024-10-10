#!/bin/bash

set -euxo pipefail

PSQL="psql $DATABASE_URL -v ON_ERROR_STOP=1"

# download sample sites, snap to streams
bcdata bc2pg WHSE_FISH.FISS_STREAM_SAMPLE_SITES_SP
$PSQL -f sql/fiss_stream_sample_sites_events.sql

$PSQL -f sql/fiss_sample_sites_gradient.sql --csv > fiss_sample_sites_gradient.sql