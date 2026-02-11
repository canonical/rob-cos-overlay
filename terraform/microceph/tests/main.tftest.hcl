run "basic_deploy" {
  command = apply

  assert {
    condition     = module.microceph.app_name != ""
    error_message = "microceph app_name should be set"
  }

  assert {
    condition     = module.microceph.requires.traefik_route_rgw == "traefik-route-rgw"
    error_message = "requires should expose traefik-route-rgw"
  }

  assert {
    condition     = module.microceph.requires.identity_service == "identity-service"
    error_message = "requires should expose identity-service"
  }

  assert {
    condition     = module.microceph.requires.receive_ca_cert == "receive-ca-cert"
    error_message = "requires should expose receive-ca-cert"
  }

  assert {
    condition     = module.microceph.provides.ceph == "ceph"
    error_message = "provides should expose ceph"
  }

  assert {
    condition     = module.microceph.provides.radosgw == "radosgw"
    error_message = "provides should expose radosgw"
  }

  assert {
    condition     = module.microceph.provides.mds == "mds"
    error_message = "provides should expose mds"
  }

  assert {
    condition     = module.microceph.provides.cos_agent == "cos-agent"
    error_message = "provides should expose cos-agent"
  }
}
