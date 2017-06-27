#!/usr/bin/ruby
require 'optparse'
require 'nokogiri'
require 'scanf'

# This vvvv handles the case no arg was provided.
ARGV << '-h' if ARGV.empty?

#
# given an XML .svd file as input, this ditty works
# through the hierarchy producing a GDB script file.
# This script is of a form that will dump the regs for
# your arch so you can do a before/after register triage.
#

$options = {}
$options[:verbose] = false
$options[:emitbigblocks] = false
$options[:svd] = ""
$options[:output] = ""
$options[:skiplist] = []
$options[:onlylist] = []
$options[:sizelim] = 8192

OptionParser.new do |opts|
  opts.banner = "Usage: svd2gdb.rb [$options]"
  opts.on("-l", "--list", 'List sheets') do
    $options[:list] = true
  end

  opts.on("-v", "--verbose", 'Disable redirect. All output is seen. No faster btw...') do
    $options[:verbose] = true
  end

  opts.on("-B", "--emitbigblocks", 'emit blocks > sizelimit no matter the cost in time.') do
    $options[:emitbigblocks] = true
  end
  
  opts.on("-s", "--svdfile=SVDFILENAME", 'svd input') do |x|
    $options[:svd] = x
  end

  opts.on("-x", "--skiplist=COMMALIST", 'comma separated list of unwanted modules') do |x|
    $options[:skiplist] = x
  end

  opts.on("-O", "--onlylist=COMMALIST", 'comma separated list of only wanted modules') do |x|
    $options[:onlylist] = x
  end
  
  opts.on("-o", "--output=OUTPUTFILENAME", 'output') do |x|
    $options[:output] = x
  end

  opts.on("-L", "--sizelimit=<decnum>", 'decnum default is 8192') do |x|
    $options[:sizelim] = x.to_i
  end
  
  opts.on_tail("-h", "--help", 'this list') do 
    puts opts
    exit
  end
end.parse!

if $options[:svd] == ""
  puts "Need an svd filename"
  exit
end

if $options[:output] == ""
  puts "Need an output filename"
  exit
end

skiplist = nil
if $options[:skiplist] != [] then
  skiplist = Hash.new
  $options[:skiplist].split(',').each do |x|
    skiplist[x.upcase] = true
  end
end

onlylist = nil
if $options[:onlylist] != [] then
  onlylist = Hash.new
  $options[:onlylist].split(',').each do |x|
    onlylist[x.upcase] = true
  end
end

doc=File.open($options[:svd]) { |f| Nokogiri::XML(f) }

per =  doc.xpath("//peripheral")

fout = File.open($options[:output], "w")
if not fout then
  printf "Error opening %s for output", $options[:output]
  exit
end

fout.syswrite("set pagination off\n")

per.each do |x|
  name = x.xpath('name')
  if skiplist && skiplist[name.text.upcase] then # user did not want this in the dump
    next
  end
  if onlylist && (not onlylist[name.text.upcase]) then # user wants specific peripherals
    next
  end
  ba = x.xpath('baseAddress')
  bsize = x.xpath('addressBlock/size');
  if bsize[0] then
    asize = bsize.text.scanf "%x"
    if (asize[0] > $options[:sizelim]) && (not $options[:emitbigblocks]) then
      printf "Skipping block %s for size > lim %d got %d (use -B if needed)\n", name.text, $options[:sizelim],asize[0]
      next  # Skip this one
    end
    psize = ((asize[0] + 3) / 4)     # 4 bytes per x/x read
  else
    psize = 256
  end

  fout.syswrite(sprintf "set logging file %s.log\n",name.text)
  fout.syswrite("set logging on\n")
  if not $options[:verbose] then
    fout.syswrite("set logging redirect on\n")
  end
  fout.syswrite(sprintf "x/%sx %s\n",psize,ba.text)
  if not $options[:verbose] then
    fout.syswrite("set logging redirect off\n")
  end
  fout.syswrite("set logging off\n")
end
fout.close()





















