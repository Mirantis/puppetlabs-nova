$userid = 'guest'
$password = 'guest'
$port = '5672'
$virtual_host = '/'
$cluster = false
$cluster_nodes = ['10.10.0.1' , '10.10.0.2']
$enabled = true

node /controller-0[12]/ {
  class { nova::rabbitmq:
    userid => $userid,
    password => $password,
    port => $port,
    virtual_host => $virtual_host,
    cluster => $cluster,
    cluster_nodes => $cluster_nodes,
    enabled => $enabled
  }
}
