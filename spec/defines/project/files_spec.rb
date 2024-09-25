# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::project::files' do
  let(:title) { 'namevar' }
  let(:params) {
    { 
      'source'      => 'test',
      'deploy_root' => '/tmp',
      'source_baseurl' => 'http://example.com',
    }
  }

  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
