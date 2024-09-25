# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::netinstall' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'namevar' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 
          'url'             => 'test',
          'destination_url' => '/tmp',
        }
      }
      it { is_expected.to compile }
    end
  end
end
