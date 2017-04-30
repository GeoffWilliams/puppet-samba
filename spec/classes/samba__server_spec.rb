require 'spec_helper'
require 'puppet_factset'

describe 'samba::server' do
  system_name = 'SLES-12.1-64'
  let :facts do
    PuppetFactset::factset_hash(system_name)
  end

  it { should contain_file('/etc/samba/smb.conf').with_owner('root') }
  it { should contain_package('samba') }
  it { should contain_service('smb') }
  it { should contain_service('nmb') }


  it { should contain_class('samba::server') }

  context 'with hiera shares hash' do
    let(:params) {{
        'shares' => {
          'testShare' => {
            'path' => '/path/to/some/share',
            'browsable' => true,
            'writable' => true,
            'guest_ok' => true,
            'guest_only' => true,
            'msdfs_root' => true,
         },
         'testShare2' => {
            'path' => '/some/other/path'
         }
       }
    }}
    it {
      should contain_samba__server__share( 'testShare' ).with({
          'path' => '/path/to/some/share',
          'browsable' => true,
          'writable' => true,
          'guest_ok' => true,
          'guest_only' => true,
          'msdfs_root' => true,
      })
    }
    it { should contain_samba__server__share( 'testShare2' ).with_path('/some/other/path') }
  end

  context 'with hiera users hash' do
    let(:params) {{
        'users' => {
          'testUser' => {
            'password' => 'testpass01'
         },
         'testUser2' => {
            'password' => 'testpass02'
         }
       }
    }}
    it { should contain_samba__server__user( 'testUser' ).with_password('testpass01') }
    it { should contain_samba__server__user( 'testUser2' ).with_password('testpass02') }
  end

end
