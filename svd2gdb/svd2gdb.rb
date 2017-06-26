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

OptionParser.new do |opts|
  opts.banner = "Usage: svd2gdb.rb [$options]"
  opts.on("-l", "--list", 'List sheets') do
    $options[:list] = true
  end

  opts.on("-v", "--verbose", 'Disable redirect. All output is seen. No faster btw...') do
    $options[:verbose] = true
  end

  opts.on("-B", "--emitbigblocks", 'emit blocks > 4k no matter the cost in time.') do
    $options[:emitbigblocks] = true
  end
  
  opts.on("-s", "--svdfile=SVDFILENAME", 'svd input') do |x|
    $options[:svd] = x
  end

  opts.on("-x", "--skiplist=COMMALIST", 'comma separated list of unwanted modules') do |x|
    $options[:skiplist] = x
  end
  
  opts.on("-o", "--output=OUTPUTFILENAME", 'output') do |x|
    $options[:output] = x
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

skiplist = Hash.new
if $options[:skiplist] != [] then
  $options[:skiplist].split(',').each do |x|
    skiplist[x.upcase] = true
  end
end

doc=File.open($options[:svd]) { |f| Nokogiri::XML(f) }

per =  doc.xpath("//peripheral")

fout = File.open($options[:output], "w")
if !fout then
  printf "Error opening %s for output", $options[:output]
  exit
end

fout.syswrite("set pagination off\n")

per.each do |x|
  name = x.xpath('name')
  if skiplist[name.text.upcase] then # user did not want this in the dump
    next
  end
  ba = x.xpath('baseAddress')
  bsize = x.xpath('addressBlock/size');
  if bsize[0] then
    asize = bsize.text.scanf "%x"
    if (asize[0] > 8192) && !$options[:emitbigblocks] then
      printf "Skipping block %s for size >8k %d (use -B if needed)\n", name.text, asize[0]
      next  # Skip this one
    end
    psize = ((asize[0] + 3) / 4)     # 4 bytes per x/x read
  else
    psize = 256
  end

  fout.syswrite(sprintf "set logging file %s.log\n",name.text)
  fout.syswrite("set logging on\n")
  if !$options[:verbose] then
    fout.syswrite("set logging redirect on\n")
  end
  fout.syswrite(sprintf "x/%sx %s\n",psize,ba.text)
  if !$options[:verbose] then
    fout.syswrite("set logging redirect off\n")
  end
  fout.syswrite("set logging off\n")
end
fout.close()





















