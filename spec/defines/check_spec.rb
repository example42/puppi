# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::check' do

    on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }  
      let(:title) { 'puppi::check' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 'enable'   =>  'true',
          'name'     =>  'get',
          'command'  =>  'echo',
          'priority' =>  '50',
          'project'  =>  'myapp',
        }
      }
      it { is_expected.to compile }
      describe 'Test puppi check step file creation' do
        it 'should create a puppi::check step file' do
          should contain_file('Puppi_check_myapp_50_get').with_ensure('file')
        end
        it 'should populate correctly the puppi::check step file' do
          should contain_file('Puppi_check_myapp_50_get').with_content(/\/usr\/lib64\/nagios\/plugins\/echo/)
        end
      end
  
    end
  end
end
