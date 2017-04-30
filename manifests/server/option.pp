# == Define samba::server::option
#
define samba::server::option (
    $value  = '',
) {

    # Attempt to parse variable name and value from title if it is in the form X=x
  if $title =~ /.+=.*/ {
    $split  = split($title, '=')
    $_name  = $split[0]
    $_value = $split[1]
  } else {
    $_name  = $name
    $_value = $value
  }

  include samba::params
  include samba::server
  $samba_config_dir   = $samba::params::samba_config_dir
  $samba_config_file  = $samba::params::samba_config_file
  $context            = $samba::server::context
  $target             = $samba::server::target
  $services           = $samba::params::services
  $manage_service     = $samba::server::manage_service

  $changes = $value ? {
    ''      => "rm ${target}/${_name}",
    default => "set \"${target}/${_name}\" \"${_value}\"",
  }


  augeas { "samba-${_name}":
    incl    => $samba_config_file,
    lens    => 'Samba.lns',
    context => $context,
    changes => $changes,
    require => Augeas['global-section'],
    notify  => $samba::server::notify,
  }
}
