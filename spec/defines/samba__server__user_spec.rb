require 'spec_helper'
require 'puppet_factset'

describe 'samba::server::user', :type => :define do
  system_name = 'SLES-12.1-64'
  let :facts do
    PuppetFactset::factset_hash(system_name)
  end
  let(:pre_condition){ 'class{"samba::server":}'}
  let(:title) { 'test_user' }
  let(:params) {{ :password => 'secret' }}

  it { is_expected.to contain_samba__server__user('test_user') }
  it { is_expected.to contain_exec('add smb account for test_user').with(
    :command => '/bin/echo -e \'secret\nsecret\n\' | /usr/bin/pdbedit --password-from-stdin -a \'test_user\'',
    :unless  => '/usr/bin/pdbedit \'test_user\'',
    :require => 'User[test_user]',
    :notify  => 'Class[Samba::Server::Service]'
  ) }
end
