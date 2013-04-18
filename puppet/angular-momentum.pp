# This Puppet (https://puppetlabs.com/) file declares the system configuration
# for the Vagrant system (you can also apply this manually using
# `puppet apply --modulepath=./modules:./vendor_modules angular-momentum.pp`).

# This declares a dependency on the apt class of the apt Puppet module
# (https://forge.puppetlabs.com/puppetlabs/apt)
class {'apt': 
# This configures apt to always update when provisioning
always_apt_update => true
}

# This is an alternative syntax to depend on a class (in this case, the
# nodejs class of the nodejs module). This differs from the above syntax
# in that you can include a class multiple times without an error,
# but you cannot supply parameters to include.
include nodejs

# This defines the db class
class db {
  class {'rethinkdb':
    instance_name => 'ranklist',
    driver_port => 38015,
    http_port => 8090,
    cluster_port => 39015,
  }
}

/*class frontend {
  if (!$is_virtual) {
    class {'nginx': }
    nginx::resource::vhost { 'ranklist':
      ensure => present,
      www_root => '/srv/ranklist',
      server_name => ['_']
    }

    nginx::resource::upstream { 'ranklist-backend':
      ensure => present,
      members => [
        'localhost:3000',
      ],
    }

    nginx::resource::location { 'ranklist-api':
      ensure => present,
      location => '/api',
      proxy => 'http://ranklist-backend',
      vhost => 'ranklist',
    }
  } else {
      class {'apache':}
      apache::vhost { 'ranklist':
        vhost_name      => 'localhost',
        port            => '80',
        docroot         => '/srv/ranklist',
        serveradmin     => 'tim@timdumol.com',
      }
  }
}*/

# This declares a dependency on the above defined db class
class {'db':}
