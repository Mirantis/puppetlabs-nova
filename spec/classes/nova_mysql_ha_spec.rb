require 'spec_helper'

describe 'nova::mysql_ha' do
  describe 'with defaults' do
    it 'should compile' do
      should contain_exec('patch-nova-mysql')
    end
  end
end
