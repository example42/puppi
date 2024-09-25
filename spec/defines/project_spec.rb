# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::project' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'get' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        {
          'enable'   =>  'true',
        }
      }
    
      describe 'Test puppi project configuration file' do
        it 'should create a puppi::project configuration file' do
          should contain_file('/etc/puppi/projects/get/config').with_ensure('present')
        end
      end

      it { is_expected.to compile }
    end
  end
end
