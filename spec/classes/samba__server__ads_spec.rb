require 'spec_helper'
require 'puppet_factset'

describe 'samba::server::ads', :type => :class do
  system_name = 'SLES-12.1-64'
  let :facts do
    PuppetFactset::factset_hash(system_name)
  end

  context "Default config" do
    it { should contain_exec('join-active-directory') }
  end

  context "No join" do
    let ( :params ) { { 'perform_join' => false }}
    it { should_not contain_exec('join-active-directory') }
  end

  context "Join 'forced'" do
    let ( :params ) { { 'perform_join' => true }}
    it { should contain_exec('join-active-directory') }
  end
end
