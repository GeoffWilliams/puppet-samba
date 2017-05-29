# == Class samba::server::ads
# This module join samba server to Active Dirctory
#
# In general, the equivalent smb.conf parameters will be removed when the value
# for a class parameter is set to `false`.  if you want to keep the line in the
# file but turn off the feature, the value you are looking for is probably `no`
class samba::server::ads(
  $ensure                     = present,
  $winbind_acct               = 'admin',
  $winbind_pass               = 'SecretPass',
  $winbind_uid                = '10000-20000',
  $winbind_gid                = '10000-20000',
  $winbind_enum_groups        = 'yes',
  $winbind_enum_users         = 'yes',
  $winbind_use_default_domain = 'yes',
  $nsswitch                   = false,
  $acl_group_control          = 'yes',
  $map_acl_inherit            = 'yes',
  $inherit_acls               = 'yes',
  $store_dos_attributes       = 'yes',
  $ea_support                 = 'yes',
  $dos_filemode               = 'yes',
  $acl_check_permissions      = false,
  $map_system                 = 'no',
  $map_archive                = 'no',
  $map_readonly               = 'no',
  $target_ou                  = 'Nix_Mashine',
  $perform_join               = true) {

  if $facts['os']['family'] == 'RedHat' {
    $krb5_user_package  = 'krb5-workstation'
    $winbind_package    = 'samba-winbind'
  } else {
    $winbind_package    = 'winbind'
    $krb5_user_package  = 'krb5-user'
  }

  package { [$krb5_user_package, $winbind_package, 'expect']:
    ensure => installed,
    before => Service['winbind'],
  }

  service { 'winbind':
    ensure  => running,
    enable  => true,
    require => Class['samba::server'],
  }

  # notify winbind
  Samba::Server::Option {
    notify => Service['winbind'],
  }
  samba::server::option {"winbind uid=${winbind_uid}": }
  samba::server::option {"winbind gid=${winbind_gid}": }
  samba::server::option {"winbind enum groups=${winbind_enum_groups}": }
  samba::server::option {"winbind enum users=${winbind_enum_users}": }
  samba::server::option {"winbind use default domain=${winbind_use_default_domain}": }


  samba::server::option {"acl group control=${acl_group_control}": }
  samba::server::option {"map acl inherit=${map_acl_inherit}": }
  samba::server::option {"inherit acls=${inherit_acls}": }
  samba::server::option {"store dos attributes=${store_dos_attributes}": }
  samba::server::option {"ea support=${ea_support}": }
  samba::server::option {"dos filemode=${dos_filemode}": }
  samba::server::option {"acl check permissions=${acl_check_permissions}": }
  samba::server::option {"map system=${map_system}": }
  samba::server::option {"map archive=${map_archive}": }
  samba::server::option {"map readonly=${map_readonly}": }

  $nss_file = 'etc/nsswitch.conf'

  $changes = $nsswitch ? {
      true => [
        'set database[. = "passwd"]/service[1] compat',
        'set database[. = "passwd"]/service[2] winbind',
        'set database[. = "group"]/service[1] compat',
        'set database[. = "group"]/service[2] winbind',
      ],
      false => [
        "rm /files/${nss_file}/database[. = 'passwd']/service[. = 'winbind']",
        "rm /files/${nss_file}/database[. = 'group']/service[. = 'winbind']",
      ]
    }

  augeas { 'nsswitch':
    context => "/files/${nss_file}",
    changes => $changes
  }

  file {'verify_active_directory':
    # this script returns 0 if join is intact
    path    => '/sbin/verify_active_directory',
    owner   => root,
    group   => root,
    mode    => '0750',
    content => template("${module_name}/verify_active_directory.erb"),
    require => [ Package[$krb5_user_package, $winbind_package, 'expect'],
      Augeas['samba-realm', 'samba-security', 'samba-winbind enum users',
        'samba-winbind enum groups', 'samba-winbind uid', 'samba-winbind gid',
        'samba-winbind use default domain'], Service['winbind'] ],
  }

  file {'configure_active_directory':
    # this script joins or leaves a domain
    path    => '/sbin/configure_active_directory',
    owner   => root,
    group   => root,
    mode    => '0750',
    content => template("${module_name}/configure_active_directory.erb"),
    require => [ Package[$krb5_user_package, $winbind_package, 'expect'],
      Augeas['samba-realm', 'samba-security', 'samba-winbind enum users',
        'samba-winbind enum groups', 'samba-winbind uid', 'samba-winbind gid',
        'samba-winbind use default domain'], Service['winbind'] ],
  }

  if ($perform_join) {
    exec {'join-active-directory':
      # join the domain configured in samba.conf
      command => '/sbin/configure_active_directory -j',
      unless  => '/sbin/verify_active_directory',
      require => [ File['configure_active_directory', 'verify_active_directory'], Service['winbind'] ],
    }
  }
}
