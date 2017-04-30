#@PDQTest
#
# A basic fully functional samba server
class { 'samba::server':
  workgroup     => 'example',
  server_string => 'Example Samba Server'
}

samba::server::share {'example-share':
  comment              => 'Example Share',
  path                 => '/path/to/share',
  guest_only           => true,
  guest_ok             => true,
  guest_account        => 'guest',
  browsable            => false,
  create_mask          => 0777,
  force_create_mask    => 0777,
  directory_mask       => 0777,
  force_directory_mode => 0777,
  force_group          => 'group',
  force_user           => 'user',
  hide_dot_files       => false,
  msdfs_root           => true,
}
