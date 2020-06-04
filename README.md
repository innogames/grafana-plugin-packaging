# DEB and RPM packager for grafana plugins
This simple [Makefile](./Makefile) allows to build package with grafana plugin, that could be installed as usual software.

To build package run it as `make plugin_id:version`, it will:

- Run grafana docker image
- Install plugin there from the official repository. NOTE: additional parameters could be passed with `GRAFANA_CLI_ARGS`, see `%` target. Custom `--pluginsDir` is not supported.
- Export downloaded plugin into `plugin:version` directory
- Build the deb and rpm packages
- If `$RESTART_ON_UPGRADE` environment variable is set in `/etc/default/grafana-server`, then server will be restarted during package install/upgrade/remove

## Requirements

- Docker
- [fpm](https://github.com/jordansissel/fpm)
- GNU make
