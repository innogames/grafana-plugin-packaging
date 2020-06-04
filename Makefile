NAME = grafana-plugin-package
VENDOR = "System Administration <it@innogames.com>"
URL = https://github.com/innogames/$(NAME)
PACKAGE_PREFIX = grafana-plugin-
define DESC =
Grafana plugin $(PLUGIN_ID)
 Packaged via $(URL) software. For info about the plugin itself see https://grafana.com/grafana/plugins/$(PLUGIN_ID)
endef

AVAILABLE_PLUGINS = $(shell docker run --rm --entrypoint grafana-cli grafana/grafana plugins list-remote | sed -e '/^id:/ s/id: \(\S*\) version: \(S*\)/\1:\2/p; d')
CONTAINER = grafana-plugin-builder
THIS_FILE = $(lastword $(MAKEFILE_LIST))
GRAFANA_CLI_ARGS = 

.PHONY: all help

all: help

help:
	@echo 'Build the package with requested name:version'
	@echo 'Dependencies: docker, fpm (package builder)'
	@echo 'To get list of available plugins with the latest versions run `make list`'

list:
	@echo Available: $(AVAILABLE_PLUGINS) | tr ' ' '\n'

clean:
	rm -rf *:* *.deb *.rpm

# Default target to build any plugin
%: ID = $(word 1,$(subst :, ,$@))
%: VERSION = $(word 2,$(subst :, ,$@))
%: PACKAGE_NAME = $(PACKAGE_PREFIX)$(ID)
%:
	@if [ -z '$(VERSION)' ]; then echo 'Target does not contain VERSION part. See `make help`'; exit 1; fi
	-docker rm $(CONTAINER)
	docker run --name $(CONTAINER) --entrypoint grafana-cli grafana/grafana $(GRAFANA_CLI_ARGS) plugins install '$(ID)' '$(VERSION)'
	mkdir $@
	docker export $(CONTAINER) | tar x -C $@ 'var/lib/grafana/plugins/$(ID)'
	docker rm $(CONTAINER)
	$(MAKE) -f $(THIS_FILE) PLUGIN_ID=$(ID) PACKAGE_NAME=$(PACKAGE_NAME) VERSION=$(VERSION) '$(PACKAGE_NAME)_$(VERSION)_amd64.deb'
	$(MAKE) -f $(THIS_FILE) PLUGIN_ID=$(ID) PACKAGE_NAME=$(PACKAGE_NAME) VERSION=$(VERSION) '$(PACKAGE_NAME)-$(VERSION)-1.x86_64.rpm'

export DESC
%.deb %.rpm: TYPE = $(subst .,,$(suffix $@))
%.deb %.rpm:
	fpm --verbose \
		-s dir \
		-a x86_64 \
		-t $(TYPE) \
		--vendor $(VENDOR) \
		-m $(VENDOR) \
		--url $(URL) \
		--description "$$DESC" \
		--license MIT \
		--depends grafana \
		-n $(PACKAGE_NAME) \
		-v $(VERSION) \
		--after-install restart-grafana \
		--after-remove  restart-grafana \
		$(PLUGIN_ID):$(VERSION)/=/

