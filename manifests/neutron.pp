class openstack_integration::neutron {

  include ::openstack_integration::config

  rabbitmq_user { 'neutron':
    admin    => true,
    password => 'an_even_bigger_secret',
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { 'neutron@/':
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }

  class { '::neutron::db::mysql':
    password => 'neutron',
  }
  class { '::neutron::keystone::auth':
    password => 'a_big_secret',
  }
  class { '::neutron':
    rabbit_user           => 'neutron',
    rabbit_password       => 'an_even_bigger_secret',
    rabbit_host           => $::openstack_integration::config::rabbit_host,
    rabbit_port           => $::openstack_integration::config::rabbit_port,
    rabbit_use_ssl        => $::openstack_integration::config::ssl,
    allow_overlapping_ips => true,
    core_plugin           => 'ml2',
    service_plugins       => [ 'metering'],#MA
    debug                 => true,
    verbose               => true,
  }
  class { '::neutron::client': }
  class { '::neutron::server':
    database_connection => 'mysql+pymysql://neutron:neutron@127.0.0.1/neutron?charset=utf8',
    password            => 'a_big_secret',
    sync_db             => true,
    api_workers         => 2,
    rpc_workers         => 2,
    auth_uri            => $::openstack_integration::config::keystone_auth_uri,
    auth_url            => $::openstack_integration::config::keystone_admin_uri,
  }
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vlan'],
    tenant_network_types => ['vlan'],
    mechanism_drivers    => linuxbridge,
    firewall_driver      => 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver',
    network_vlan_ranges  => ["external:401:410"],
  }
  class { '::neutron::agents::ml2::linuxbridge':
    tunnel_types                => ['vlan'],
    physical_interface_mappings => ["external:eth0"],
  }
#  class { '::neutron::plugins::ml2':
#    type_drivers         => ['vxlan'],
#    tenant_network_types => ['vxlan'],
#    mechanism_drivers    => ['openvswitch'],
#  }
#  class { '::neutron::agents::ml2::ovs':
#    enable_tunneling => true,
#    local_ip         => '127.0.0.1',
#    tunnel_types     => ['vxlan'],
#  }
  class { '::neutron::agents::metadata':
    debug            => true,
    shared_secret    => 'a_big_secret',
    metadata_workers => 2,
    metadata_ip => $::ipaddress_eth0,

  }
#  class { '::neutron::agents::lbaas':
#    debug => true,
#  }
#  class { '::neutron::agents::l3':
#    debug => true,
#  }
  class { '::neutron::agents::dhcp':
    debug => true,
    interface_driver => 'neutron.agent.linux.interface.BridgeInterfaceDriver',
    dhcp_delete_namespaces => true,
    enable_isolated_metadata => true,
    enable_metadata_network => true,
  }

  class { '::neutron::agents::metering':
    debug => true,
    interface_driver => 'neutron.agent.linux.interface.BridgeInterfaceDriver',
  }

  class { '::neutron::server::notifications':
    auth_url => $::openstack_integration::config::keystone_admin_uri,
    password => 'a_big_secret',
  }
#  class { '::neutron::services::fwaas':
#    enabled => true,
#    driver  => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
#  }
#  include ::vswitch::ovs

}
