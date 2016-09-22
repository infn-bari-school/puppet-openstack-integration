class openstack_integration::horizon {

  $vhost_params = { add_listen => false }
  class { '::horizon':
    secret_key         => 'big_secret',
    vhost_extra_params => $vhost_params,
    servername         => $::hostname,
    allowed_hosts      => '*',
    # need to disable offline compression due to
    # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
    compress_offline   => false,


    neutron_options => {
#      'enable_lb' => true,
      'enable_firewall' => true,
#      'enable_vpn' => true,
      'enable_router' => false,
      'enable_quotas' => true,
      'enable_security_group' => true,
    },
  }

}
