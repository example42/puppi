# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::run' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'myapp' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 
          'project'  =>  'myapp',
        }
      }
    
      describe 'Test puppi run exe creation' do
        it { should contain_exec('Run_Puppi_myapp').with_command(/puppi deploy myapp/) }
      end

      it { is_expected.to compile }
    end
  end
end
