require 'jasminerice-runner/reporter'

module Jasminerice
  class Runner
    cattr_accessor :capybara_driver
  end
  class JasmineRiceRunnerEngine < Rails::Engine
  end
end
