# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::check' do
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

  describe 'Test puppi check step file creation' do
    it 'should create a puppi::check step file' do
      should contain_file('Puppi_check_myapp_50_get').with_ensure('present')
    end
    it 'should populate correctly the puppi::check step file' do
      should contain_file('Puppi_check_myapp_50_get').with_content(/\/usr\/lib64\/nagios\/plugins\/echo/)
    end
  end
  
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
