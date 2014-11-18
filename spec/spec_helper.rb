require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'grid_struct'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end
