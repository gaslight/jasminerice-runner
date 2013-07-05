module Jasminerice
  class Runner
    include Capybara::DSL

    def initialize(environment)
      @environment = environment
      @reporter = Reporter.new
    end

    def capybara_driver
      self.class.capybara_driver || :selenium
    end

    def run
      Capybara.default_driver = capybara_driver
      visit jasmine_url
      print "Running jasmine specs\n"

      wait_for_finished
      @reporter.report(get_results)
    end

    def jasmine_url
      url = "/jasmine"
      if @environment.present?
        url += "?environment=#{@environment}"
      end

      url
    end

    def get_results
      {
        passed: page.evaluate_script("window.jasmineRiceReporter.results.passedCount"),
        failed: page.evaluate_script("window.jasmineRiceReporter.results.failedCount"),
        total: page.evaluate_script("window.jasmineRiceReporter.results.totalCount"),
        failures: page.evaluate_script("window.jasmineRiceReporter.failedSpecs")
      }
    end

    def wait_for_finished
      find_jasmine_reporter
      start = Time.now
      while true
        break if page.evaluate_script("window.jasmineRiceReporter.finished")
        sleep 1
        print "."
      end
    end

    private

    def find_jasmine_reporter
      reporter = page.evaluate_script("window.jasmineRiceReporter")
      if reporter.nil?
        if @environment.present?
          filename = "#{@environment}_spec.js"
        else
          filename = "spec.js"
        end
        puts "\njasmineRiceReporter not defined! Check your configuration to make\n" +
             "sure that #{filename} exists and that jasminerice_reporter is included."
        raise "Reporter not found"
      end
    end
  end
end
