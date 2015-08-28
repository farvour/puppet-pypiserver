require 'spec_helper'
describe 'pypiserver' do

  context 'with defaults for all parameters' do
    it { should contain_class('pypiserver') }
  end
end
