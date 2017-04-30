# == Class samba::server::winbind
#
class samba::server::winbind ($ensure = running, $enable = true) {
  $service_name = 'winbind'

  package { ['samba-winbind', 'samba-winbind-clients', 'pam_krb5']:
    ensure => present,
  }

  service { $service_name:
    ensure     => $ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $enable,
    require    => Class['samba::server'],
  }
}
