# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::deploy' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'puppi::deploy' }
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
    
      describe 'Test puppi deploy step file creation' do
        it 'should create a puppi::deploy step file' do
          should contain_file('/etc/puppi/projects/myapp/deploy/50-get').with_ensure('file')
        end
        it 'should populate correctly the puppi::deploy step file' do
          should contain_file('/etc/puppi/projects/myapp/deploy/50-get').with_content("su - root -c \"export project=myapp && /etc/puppi/scripts/echo \"\n")
        end
      end

      it { is_expected.to compile }
    end
  end
end
