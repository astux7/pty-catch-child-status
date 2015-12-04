#!/usr/bin/env ruby

require 'pty'


cmd = "bundle exec rspec"
puts 'START TESTS'

def spawn(cmd, &block)
  begin
    proc_id = nil
    PTY.spawn(cmd) do |stdout, stdin, pid|

      proc_id = pid
      begin
        stdout.each { |line|
          #return 1 if /^*Failure\/Error/.match(line)
          yield line
        }
      rescue Errno::EIO
        puts "Errno:EIO error, but this probably just means that the process has finished giving output"
      end
      #Process.wait(pid)
    end

    PTY.check(proc_id, false).to_i
  rescue => e
    puts "Some other error: #{e.message}"
    1
  end
  $?.exitstatus
end



exit_code = spawn(cmd) do |line|
  STDOUT.puts line.rstrip
end

if exit_code > 0
  puts "Tests failed, rolling back"
  STDERR.puts "Integration tests failed! Application was rolled back."
  exit 1
else
  puts "Tests passed, promoting build to production"
  exit 0
end
