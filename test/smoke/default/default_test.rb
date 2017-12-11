# encoding: utf-8

# Inspec test for recipe timezone_iii::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end

describe command('date +%Z') do
  its('exit_status') { should eq 0 }
  its('stderr') { should eq '' }
  its('stdout') { should eq "+03\n" }
end

node = JSON.parse(command('ohai').stdout)

is_localtime_symlink = case node['platform_family']
                       when 'rhel'
                         node['platform_version'].to_i >= 7
                       when 'debian'
                         true
                       when 'amazon'
                         false
                       end

control 'localtime-link' do
  describe file('/etc/localtime') do
    it { should be_symlink }
    its('link_path') { should match /Turkey/ }
  end

  only_if { is_localtime_symlink }
end

control 'localtime-file' do
  describe file('/etc/localtime') do
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should eq 0o644 }
  end

  only_if { !is_localtime_symlink }
end

describe.one do
  # RHEL-based platforms
  describe file('/etc/sysconfig/clock') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should eq 0o644 }
    content = %{ZONE="Turkey"\n}
    its('content') { should eq content }
  end

  # Debian-based platforms
  describe file('/etc/timezone') do
    tz = 'Europe/Istanbul'
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should eq 0o644 }
    its('content') { should eq "#{tz}\n" }
  end
end
