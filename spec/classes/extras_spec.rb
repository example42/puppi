# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::extras' do
  let(:node) { 'rspec.example42.com' }
  let(:pre_condition) { 'include puppi' }
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
    end
  end
end
