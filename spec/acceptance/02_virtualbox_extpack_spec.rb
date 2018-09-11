require 'spec_helper_acceptance'

describe 'virtualbox extpack' do
  let(:install) do
    <<-EOS
    include virtualbox

    virtualbox::extpack { 'Oracle_VM_VirtualBox_Extension_Pack':
      ensure           => present,
      source           => 'http://download.virtualbox.org/virtualbox/5.1.38/Oracle_VM_VirtualBox_Extension_Pack-5.1.38.vbox-extpack',
      checksum_string  => '008cfd5aca246552f98df97614bdb7e1',
      follow_redirects => true,
    }
    EOS
  end

  let(:uninstall) do
    <<-EOS
    include virtualbox

    virtualbox::extpack { 'Oracle_VM_VirtualBox_Extension_Pack':
      ensure           => absent,
      source           => 'http://download.virtualbox.org/virtualbox/5.1.38/Oracle_VM_VirtualBox_Extension_Pack-5.1.38.vbox-extpack',
      checksum_string  => '008cfd5aca246552f98df97614bdb7e1',
      follow_redirects => true,
    }
    EOS
  end

  context 'with puppet/archive' do
    before(:all) do
      hosts.each do |host|
        on host, puppet('module', 'install', 'puppet-archive')
      end
    end

    context 'install extpack' do
      it 'is idempotent' do
        apply_manifest(install, catch_failures: true)
        apply_manifest(install, catch_changes: true)
      end

      describe file('/usr/lib/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack') do
        it { is_expected.to be_directory }
      end

      describe file('/usr/src/Oracle_VM_VirtualBox_Extension_Pack.tgz') do
        it { is_expected.to be_file }
        its(:md5sum) { is_expected.to eq '41f1d66e0be1c183917c95efed89db56' }
      end

      describe command('VBoxManage list extpacks') do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{Extension Packs: 1} }
      end
    end

    context 'uninstall extpack' do
      it 'is idempotent' do
        apply_manifest(install, catch_failures: true)
        apply_manifest(uninstall, catch_failures: true)
        apply_manifest(uninstall, catch_changes: true)
      end

      describe file('/usr/lib/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack') do
        it { is_expected.not_to be_directory }
      end

      describe file('/usr/src/Oracle_VM_VirtualBox_Extension_Pack.tgz') do
        it { is_expected.not_to be_file }
      end

      describe command('VBoxManage list extpacks') do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{Extension Packs: 0} }
      end
    end
  end
end
