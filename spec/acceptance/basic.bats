@test "check map to guest is 'Never' by default" {
  grep 'map to guest = Never' < /etc/samba/smb.conf
}

@test "guest account is 'nobody' by default" {
  grep 'guest account = nobody' < /etc/samba/smb.conf
}

@test "restrict anonymous is 1 by default" {
  grep 'restrict anonymous = 1' < /etc/samba/smb.conf
}
