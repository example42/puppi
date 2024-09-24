# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::project' do
  let(:title) { 'puppi::project' }
  let(:node) { 'rspec.example42.com' }
  let(:params) {
    { 'enable'   =>  'true',
      'name'     =>  'get',
      'command'  =>  'echo',
      'priority' =>  '50',
      'project'  =>  'myapp',
    }
  }

  describe 'Test puppi report step file creation' do
    it 'should create a puppi::report step file' do
      should contain_file('/etc/puppi/projects/myapp/report/50-get').with_ensure('present')
    end
    it 'should populate correctly the puppi::report step file' do
      should contain_file('/etc/puppi/projects/myapp/report/50-get').with_content("su - root -c \"export project=myapp && /etc/puppi/scripts/echo \"\n")
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
