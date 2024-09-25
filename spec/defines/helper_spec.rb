# frozen_string_literal: true

require 'spec_helper'

describe 'puppi::helper' do
  on_supported_os.select { |k, _v| k == 'redhat-8-x86_64'  }.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'spec' }
      let(:node) { 'rspec.example42.com' }
      let(:pre_condition) { 'include puppi' }
      let(:params) {
        { 'template'   => 'puppi/helpers/standard.yml.erb'  }
      }
    
      describe 'Test puppi helper file creation' do
        it 'should create a puppi helper file' do
          should contain_file('puppi_helper_spec').with_ensure('present')
        end
        it 'should populate correctly the helper file' do
          should contain_file('puppi_helper_spec').with_content(/info/)
        end
      end
      it { is_expected.to compile }
    end
  end
end
