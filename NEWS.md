# valh 0.2.0 (2026-02-12)

## Fix

- Don't parse `osm_changeset` as a date in `vl_status` function (fixes [#2](https://github.com/riatelab/valh/issues/2))
- `vl_status()` no longer gives a check warning nor error if the resource is not available (fixes CRAN comment)
- Use POST requests instead of GET for all services (PR [#6](https://github.com/riatelab/valh/pull/6))


# valh 0.1.0 (2025-04-09)

- Initial release.
