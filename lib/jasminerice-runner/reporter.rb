module Jasminerice
  class Reporter
    attr_reader :results

    def report(results)
      @results = results
      total_report

      if failures.size == 0
        puts "Jasmine specs passed, yay!"
      else
        report_failures
        raise "Jasmine specs failed"
      end
    end

    def report_failures
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

    def total_report
      text =  "Jasmine results - Passed: #{results[:passed]} Failed: #{results[:failed]} Total: #{results[:total]}"
      if failures.any?
        puts red text
      else
        puts green text
      end
    end

    protected

    def failures
      @results[:failures]
    end

    def colorize(text, color_code) "#{color_code}#{text}\e[0m" ; end

    def red(text); colorize(text, "\e[1m\e[31m"); end
    def green(text); colorize(text, "\e[1m\e[32m"); end
  end
end
