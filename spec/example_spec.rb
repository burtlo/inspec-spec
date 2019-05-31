require 'spec_helper'
require 'libraries/example'

describe_inspec_resource 'example' do
  context 'on windows' do
    let(:platform) { 'windows' }

    environment do
      command('C:\example\bin\example.bat --version').returns(stdout: '0.1.0 (windows-build)')
    end

    its(:version) { should eq('0.1.0') }
  end

  context 'on linux' do
    let(:platform) { 'linux' }

    environment do
      command('/usr/bin/example --version').returns(stdout: '0.1.0 (GNULinux-build)')
    end

    its(:version) { should eq('0.1.0') }
  end
end