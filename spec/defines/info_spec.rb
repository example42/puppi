# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::info' do
  let(:title) { 'puppi::info' }
  let(:node) { 'rspec.example42.com' }
  let(:params) {
    { 'name'         =>  'sample',
      'description'  =>  'Sample Info',
      'templatefile' =>  'puppi/info.erb',
      'run'          =>  'myownscript',
    }
  }

  describe 'Test puppi info step file creation' do
    it 'should create a puppi::info step file' do
      should contain_file('/etc/puppi/info/sample').with_ensure('present')
    end
    it 'should populate correctly the puppi::info step file' do
      should contain_file('/etc/puppi/info/sample').with_content(/myownscript/)
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
