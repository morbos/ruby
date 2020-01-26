#! /usr/bin/ruby
#
# patcher.rb: Patch a 32bit cell at a specific offset
#
require 'optparse'

# This vvvv handles the case no arg was provided.
ARGV << '-h' if ARGV.empty?

$options = {}
$options[:debug] = false
$options[:offset] = 0
$options[:want] = 0
$options[:expect] = 0

OptionParser.new do |opts|
  opts.banner = "Usage: patcher.rb [$options]"
  opts.on("-d", "--debug", 'enable debug') do
    $options[:debug] = true
  end
  opts.on("-o", "--offset=off", 'offset') do |x|
    $options[:offset] = x.to_i(16)
  end
  opts.on("-w", "--want=", 'wanted value') do |x|
    $options[:want] = x.to_i(16)
  end
  opts.on("-e", "--expect=", 'expected value') do |x|
    $options[:expect] = x.to_i(16)
  end
  opts.on_tail("-h", "--help", 'this list') do
    puts opts
    exit
  end
end.parse!

# p ARGV[0]

fin = File.open(ARGV[0], "r+b")
if fin
  fin.sysseek($options[:offset], IO::SEEK_SET)
  x=fin.read(4).unpack("L<");
#  p x[0],$options[:expect]
  if x[0] == $options[:expect]
    fin.sysseek($options[:offset], IO::SEEK_SET)
    fin.write([$options[:want]].pack('L<'))
  else
    p "not found"
  end
  fin.close()
else
  p "open fail"
end
