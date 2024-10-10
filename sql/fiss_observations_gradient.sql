select
  source,
  species_code,
  observation_date,
  utm_zone,
  utm_easting,
  utm_northing,
  life_stage_code,
  watershed_code,
  blue_line_key,
  --stream_order,
  --max_gradient_ds,
  --max_gradient100m_ds,
  --migration_dist_total,
  --migration_dist_lt05,
  --migration_dist_05_10,
  --migration_dist_10_15,
  --migration_dist_15_20,
  --migration_dist_20_25,
  --migration_dist_25_30,
  --migration_dist_gt30
from bcfishobs.fiss_fish_obsrvtn_events_vw
where species_code in ('CH','CM','CO','PK','SK','ST')
