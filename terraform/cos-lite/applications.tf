module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform?ref=d54ed3e232a6a392d9ae67fc20de1e9ea75c7a52"
  app_name           = var.alertmanager.app_name
  channel            = var.channel
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model_uuid         = var.model_uuid
  revision           = var.alertmanager.revision
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform?ref=1386d068df1e3dee63e53cb65fce5708eaea8389"
  app_name           = var.catalogue.app_name
  channel            = var.channel
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model_uuid         = var.model_uuid
  revision           = var.catalogue.revision
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=97cdd7fc90563a0d3fa5186c57290de0e18a2c43"
  app_name           = var.grafana.app_name
  channel            = var.channel
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model_uuid         = var.model_uuid
  revision           = var.grafana.revision
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
}

module "loki" {
  source             = "git::https://github.com/canonical/loki-k8s-operator//terraform?ref=c9c288b77cd3057374bb75fc7951da23d7300800"
  app_name           = var.loki.app_name
  channel            = var.channel
  config             = var.loki.config
  constraints        = var.loki.constraints
  model_uuid         = var.model_uuid
  storage_directives = var.loki.storage_directives
  revision           = var.loki.revision
  units              = var.loki.units
}

module "prometheus" {
  source             = "git::https://github.com/canonical/prometheus-k8s-operator//terraform?ref=f60376ce0ac5c670223c4ba5b8b612b3e16d3770"
  app_name           = var.prometheus.app_name
  channel            = var.channel
  config             = var.prometheus.config
  constraints        = var.prometheus.constraints
  model_uuid         = var.model_uuid
  storage_directives = var.prometheus.storage_directives
  revision           = var.prometheus.revision
  units              = var.prometheus.units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform?ref=64d92fd32b3c77ad9eb0783d4a1bb640b9dcfab5"
  app_name    = var.ssc.app_name
  channel     = var.ssc.channel
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model_uuid  = var.model_uuid
  revision    = var.ssc.revision
  units       = var.ssc.units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform?ref=685bad8248fd75c7eb540deae7bc9528e444552e"
  app_name           = var.traefik.app_name
  channel            = var.traefik.channel
  config             = var.traefik.config
  constraints        = var.traefik.constraints
  model_uuid         = var.model_uuid
  revision           = var.traefik.revision
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}
