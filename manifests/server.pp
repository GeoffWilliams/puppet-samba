# == Class samba::server
#
# In general, the equivalent smb.conf parameters will be removed when the value
# for a class parameter is set to `false`.  if you want to keep the line in the
# file but turn off the feature, the value you are looking for is probably `no`
class samba::server(
    $interfaces               = false,
    $security                 = false,
    $server_string            = false,
    $unix_password_sync       = false,
    $bind_interfaces_only     = 'yes',
    $realm                    = false,
    $machine_password_timeout = false,
    $unix_extensions          = 'no',
    $netbios_name             = false,
    $workgroup                = false,
    $socket_options           = false,
    $deadtime                 = false,
    $keepalive                = false,
    $load_printers            = false,
    $printing                 = false,
    $printcap_name            = false,
    $map_to_guest             = 'Never',
    $guest_account            = 'nobody',
    $disable_spoolss          = false,
    $kernel_oplocks           = false,
    $pam_password_change      = false,
    $os_level                 = false,
    $preferred_master         = false,
    $shares                   = {},
    $users                    = {},
    $restrict_anonymous       = 1,

    $manage_package           = true,
    $manage_service           = true,
    $service_enable           = true,
    $service_ensure           = 'running',

) {

  include samba::params
  $samba_config_dir   = $samba::params::samba_config_dir
  $samba_config_file  = $samba::params::samba_config_file
  $context            = "/files${samba_config_file}"
  $target             = 'target[. = "global"]'
  $services           = $samba::params::services

  $notify = $manage_service ? {
    true  => Service[$services],
    false => undef,
  }

  if $manage_package {
    ensure_packages('samba', {ensure => installed})
  }

  file { $samba_config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $samba_config_file:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $manage_service {
    $services.each |$service| {
      service { $service :
        ensure    => $service_ensure,
        enable    => $service_enable,
        subscribe => File[$samba_config_file],
      }
    }
  }



  augeas { 'global-section':
    incl    => $samba_config_file,
    lens    => 'Samba.lns',
    context => $context,
    changes => "set ${target} global",
    require => File[$samba_config_file],
    notify  => Service[$samba::params::services],
  }


  samba::server::option {"realm=${realm}": }
  samba::server::option {"machine password timeout=${machine_password_timeout}": }
  samba::server::option {"unix extensions=${unix_extensions}": }
  samba::server::option {"interfaces=${interfaces}": }
  samba::server::option {"bind interfaces only=${bind_interfaces_only}": }
  samba::server::option {"security=${security}": }
  samba::server::option {"server string=${server_string}": }
  samba::server::option {"unix password sync=${unix_password_sync}": }
  samba::server::option {"netbios name=${netbios_name}": }
  samba::server::option {"workgroup=${workgroup}": }
  samba::server::option {"socket options=${socket_options}": }
  samba::server::option {"deadtime=${deadtime}": }
  samba::server::option {"keepalive=${keepalive}": }
  samba::server::option {"load printers=${load_printers}": }
  samba::server::option {"printing=${printing}": }
  samba::server::option {"printcap name=${printcap_name}": }
  samba::server::option {"map to guest=${map_to_guest}": }
  samba::server::option {"guest account=${guest_account}": }
  samba::server::option {"disable spoolss=${disable_spoolss}": }
  samba::server::option {"kernel oplocks=${kernel_oplocks}": }
  samba::server::option {"pam password change=${pam_password_change}": }
  samba::server::option {"os level=${os_level}": }
  samba::server::option {"preferred master=${preferred_master}": }
  samba::server::option {"restrict anonymous=${restrict_anonymous}": }

  create_resources(samba::server::share, $shares)
  create_resources(samba::server::user, $users)
}
