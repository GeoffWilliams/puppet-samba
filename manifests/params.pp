# Class: samba::params
#
# This class defines default parameters used by the main module class samba
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to samba class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class samba::params {

  case $facts['os']['family'] {
    'Redhat': {
      $services     = ['smb']
      # $service_name = 'smb'
      # $nmbd_name    = undef
    }
    'Debian': {
      $services = "smbd"
      case $facts['os']['name'] {
        'Debian': {
          case $facts['os']['release']['major'] {
            '8': { $services = ['smbd'] }
            default: { $services = ['samba'] }
          }
          # $nmbd_name = undef
        }
        'Ubuntu': {
          $service = ['smbd', 'nmbd']
          # $service_name = 'smbd'
          # $nmbd_name    = 'nmbd'
        }
        default: { $service_name = 'samba' }
      }
    }
    'Gentoo': {
      $services     = ['samba']
      # $service      = 'samba'
      # $nmbd_name    = undef
      # $service_name = 'samba'
    }
    'Archlinux': {
      $service = ['smbd', 'nmbd']
      # $service_name = 'smbd'
      # $nmbd_name    = 'nmbd'
    }
    'Suse': {
      $services     = ['smb','nmb']
      # $service      = 'smb'
      # $service_name = 'smb'
      # $nmbd_name    = 'nmbd'
    }
    default: { fail("${::osfamily} is not supported by ${module_name}.") }
  }

  $samba_config_dir  = '/etc/samba'
  $samba_config_file = '/etc/samba/smb.conf'
}
