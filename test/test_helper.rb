$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), *%w[ .. lib ])))

begin
  require 'redgreen' unless ENV["TM_PID"]
rescue LoadError
end

require 'shoulda'
require 'spriter'
