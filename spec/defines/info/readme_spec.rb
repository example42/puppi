# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::info::readme' do
  let(:title) { 'namevar' }
  let(:node) { 'rspec.example42.com' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
