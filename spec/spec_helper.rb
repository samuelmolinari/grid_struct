require 'grid_struct'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end
