require './lib/notify_pit'

$stdout.sync = true
$stderr.sync = true

# This ensures the Sinatra logging actually goes to STDOUT
use Rack::CommonLogger, $stdout

run NotifyPit::App