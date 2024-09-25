# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::log' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'mylog' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 'log'         =>  '/var/log/mylog.log',
          'description' =>  'My Log',
        }
      }
    
      describe 'Test puppi log file creation' do
        it 'should create a puppi::log file' do
          should contain_file('/etc/puppi/logs/mylog').with_ensure('file')
        end
        it 'should populate correctly the puppi::log step file' do
          should contain_file('/etc/puppi/logs/mylog').with_content(/mylog.log/)
        end
      end

      it { is_expected.to compile }
    end
  end
end
