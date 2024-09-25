# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::todo' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'mytodo' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 'notes'         =>  'Test Notes',
          'description'   =>  'Test Description',
          'check_command' =>  'check_test',
          'run'           =>  'test',
        }
      }
    
      describe 'Test puppi todo file creation' do
        it 'should create a puppi::todo file' do
          should contain_file('/etc/puppi/todo/mytodo').with_ensure('file')
        end
        it 'should populate correctly the puppi::todo step file' do
          should contain_file('/etc/puppi/todo/mytodo').with_content(/check_test/)
        end
      end
    
      it { is_expected.to compile }
    end
  end
end
