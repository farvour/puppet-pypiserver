# == Class: pypiserver
#
# Configures a Python Package Index on this server.
#
# === Parameters
#
# [*package_root*]
#   Location of where the python packages will be stored.
#
# [*virtualenv_path*]
#   What the virtualenv path is created and installed to for serving pypiserver.
#
# See hiera for additional parameter information.
#
class pypiserver (
  $base_path       = '/var/www/pypiserver',
  $package_root    = '/var/www/pypiserver/packages',
  $virtualenv_path = '/var/www/pypiserver/virtualenv',
  $unix_socket     = '/tmp/pypiserver-gunicorn.sock',
) {
  file { [$base_path, $package_root]:
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  ::python::virtualenv { $virtualenv_path:
    ensure  => 'present',
    version => '3.4',
    path    => ['/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin'],
  }
  ->
  ::python::pip { 'pypiserver':
    ensure     => 'present',
    virtualenv => $virtualenv_path,
  }
  ->
  ::python::pip { 'gunicorn':
    ensure     => 'present',
    virtualenv => $virtualenv_path,
  }
  ->
  file { '/etc/init/pypiserver-gunicorn.conf':
    ensure  => 'present',
    content => template('pypiserver/upstart/pypiserver-gunicorn.erb'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
  ~>
  service { 'pypiserver-gunicorn':
    ensure    => 'running',
    enable    => true,
    provider  => 'upstart',
  }
}
