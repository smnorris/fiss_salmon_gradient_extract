#!/bin/bash

set -euxo pipefail

PSQL="psql $DATABASE_URL -v ON_ERROR_STOP=1"

# download sample sites, snap to streams, report on gradients
bcdata bc2pg WHSE_FISH.FISS_STREAM_SAMPLE_SITES_SP
$PSQL -f sql/stream_sample_sites_01_snap.sql
$PSQL -f sql/stream_sample_sites_02_gradient.sql --csv > stream_sample_sites_gradient.csv

# download observations, snap to streams
git clone https://github.com/smnorris/bcfishobs.git
cd bcfishobs
./process.sh
cd ..

# run queries
time $PSQL -f sql/observations_01_locations.sql
time $PSQL -f sql/observations_02_dnstr_gradient_max.sql