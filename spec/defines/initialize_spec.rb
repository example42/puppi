# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::initialize' do
  let(:title) { 'puppi::initialize' }
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

  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
