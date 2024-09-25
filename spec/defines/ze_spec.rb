# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::ze' do
  let(:title) { 'sample' }
  let(:node) { 'rspec.example42.com' }
  let(:pre_condition) { 'include puppi' }
  let(:params) {
    { 'helper'     => 'mytest',
      'variables'  => { 'var1' => 'get', 'var2' => 'got' },
      'name'       => 'sample',
    }
  }

  describe 'Test puppi ze data file creation' do
    it 'should create a puppi::ze step file' do
      should contain_file('puppize_sample').with_ensure('present')
    end
  end

  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
