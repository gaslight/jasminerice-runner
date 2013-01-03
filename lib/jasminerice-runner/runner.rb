module Jasminerice
  class Runner
    include Capybara::DSL

    def initialize(environment)
      @environment = environment
    end

    def capybara_driver
      self.class.capybara_driver || :selenium
    end

    def run
      Capybara.default_driver = capybara_driver
      visit jasmine_url
      print "Running jasmine specs"

      wait_for_finished
      results = get_results
      puts "Jasmine results - Passed: #{results[:passed]} Failed: #{results[:failed]} Total: #{results[:total]}"
      failures = results[:failures]

      if failures.size == 0
        puts "Jasmine specs passed, yay!"
      else
        report_failures(failures)
        raise "Jasmine specs failed"
      end
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

    def report_failures(failures)
      puts 'Jasmine failures:  '
      for suiteName,suiteFailures in failures
        puts "  " + suiteName + "\n"
        for specName,specFailures in suiteFailures
          puts "    " + specName + "\n"
          for specFailure in specFailures
            puts "      " + specFailure + "\n"
          end
        end
        puts "\n"
      end
    end

    def wait_for_finished
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

      start = Time.now
      while true
        break if page.evaluate_script("window.jasmineRiceReporter.finished")
        sleep 1
        print "."
      end
      print "\n"
    end
  end
end
