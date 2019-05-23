require "helix_runtime"

begin
  require "rainfall/native"
rescue LoadError
  warn "Unable to load rainfall/native. Please run `rake build`"
end
