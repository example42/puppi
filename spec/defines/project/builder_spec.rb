# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::project::builder' do
  let(:title) { 'namevar' }
  let(:params) {
    { 
      'source'      => 'test',
      'source_type' => 'zip',
      'deploy_root' => '/tmp',
    }
  }

  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
