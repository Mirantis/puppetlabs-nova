# This class installs a patch to nova that enables RabbitMQ HA support
# and configures the appropriate parameters.
#
# ==Parameters
#  [rabbit_nodes] List of RabbitMQ HA cluster members (host:port)
class nova::rabbitmq_ha (
    $rabbit_nodes = false
  ) {
  include nova::patch
  
  file { "/tmp/rmq-ha.patch":
    ensure => present,
    source => 'puppet:///modules/nova/rmq-ha.patch'
  }
  
  exec { 'patch-nova':
    unless  => "/bin/grep x-ha-policy /usr/lib/${::nova::params::python_path}/nova/openstack/common/rpc/impl_kombu.py",
    command => "/usr/bin/patch -p1 -d /usr/lib/${::nova::params::python_path}/nova </tmp/rmq-ha.patch",
    require => [ [File['/tmp/rmq-ha.patch']],[Package['patch', 'python-nova']]],
    subscribe => Package['python-nova']
  } ->
  # The required versions of kombu and anyjson have not been packaged yet for either Ubuntu or RedHat :(
  exec { 'update-kombu':
    command => "/usr/bin/easy_install pip; /usr/bin/pip uninstall -y kombu; /usr/bin/pip uninstall -y anyjson; /usr/bin/pip install kombu==2.4.7; /usr/bin/pip install anyjson==0.3.3; /usr/bin/pip install amqp"
  } ->
  # Do this BEFORE any nova services are started, otherwise
  # queues will be declared in non-HA mode which cannot be fixed
  # without erasing the Rabbit database.
  Nova_config <| |>
  
  nova_config { 'DEFAULT/rabbit_ha_queues': value => 'True' }

  if $rabbit_nodes {
    nova_config { 'DEFAULT/rabbit_hosts': value => inline_template("<%= @rabbit_nodes.map {|x| x+':5672'}.join ',' %>") }
  } else {
    Nova_config <<| title == 'DEFAULT/rabbit_hosts' |>>
  }
}
