require 'spec_helper'
require 'puppet_factset'

describe 'samba::server::share', :type => :define do
  let(:title) { 'test_share' }
  let(:pre_condition){ 'class{"samba::server":}'}

  system_name = 'SLES-12.1-64'
  let :facts do
    PuppetFactset::factset_hash(system_name)
  end

  context 'with base options' do
    let(:title) { 'test_share' }
    let(:params) {{
      :ensure => 'present'
    }}
    it { should compile }
    it { should contain_samba__server__share('test_share') }
    it { should contain_augeas('test_share-section')}
    it { should contain_augeas('test_share-changes')}
  end

  context 'with ensure absent' do
    let(:params) {{
      :ensure => 'absent'
    }}

    it { should contain_augeas('test_share-section').with(
      :incl    => '/etc/samba/smb.conf',
      :lens    => 'Samba.lns',
      :context => '/files/etc/samba/smb.conf',
      :changes => ["rm target[. = 'test_share'] 'test_share'"])
    }
    it { should compile }
  end

  context 'parameter passing' do
    [
      :available,
      :browsable,
      :comment,
      :copy,
      :create_mask,
      :directory_mask,
      :force_create_mode,
      :force_create_mask,
      :force_directory_mode,
      :force_group,
      :force_user,
      :guest_ok,
      :guest_only,
      :hide_unreadable,
      :path,
      :op_locks,
      :level2_oplocks,
      :veto_oplock_files,
      :read_only,
      :public,
      :read_list,
      :write_list,
      :writable,
      :printable,
      :wide_links,
      :follow_symlinks,
      :valid_users,
      :acl_group_control,
      :map_acl_inherit,
      :profile_acls,
      :store_dos_attributes,
      :strict_allocate,
      :hide_dot_files,
      :root_preexec,
      :inherit_permissions,
      :inherit_acls,
      :delete_readonly,
      :printer_name,
      :msdfs_root,
      :guest_account,
    ].each { |param|
      context "accepts parameter: #{param}" do
        let(:params) {{
          :ensure => 'present',
          param   => 'bar',
        }}
        it { should compile }
      end
    }
  end

end
