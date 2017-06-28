#!/usr/bin/ruby
require 'optparse'
require 'nokogiri'

# This vvvv handles the case no arg was provided.
ARGV << '-h' if ARGV.empty?

#
# given an XML .svd file as input and the path to the dir that
# contains log files emitted by gdb via the svd2gdb.rb script
# generator
#

def slurp(f, contents)
  pat = /\s*0x\h{8}:(.*)$/
  pat2 = /\s+(0x\h{8})/
  # read in a logfile.
  # format is:
  # addr: N dwords up to 4
  f.each_line do |l|
    # strip the address
    m = l.match(pat)
    if m && m.size == 2
      # if good, m[1] is 'the rest'
      a = m[1].scan(pat2) # scan for ea val. usually 4 till the last one
      a.each do |x|
        contents << x[0].to_i(16) # convert hex strs to the array.
      end
    end
  end
end
def rd(v, off, wid)
  mask = (1 << wid) - 1
  return (v >> off) & mask
end
def regfieldwalk(x, r, a, o)
  pname = x.xpath('name').text
  rname = r.xpath('name').text
  fblock = r.xpath('fields/field');
  fblock.each do |f|
    fname = f.xpath('name').text
    bitoff = f.xpath('bitOffset').text.to_i
    bitWid = f.xpath('bitWidth').text.to_i
    if bitWid > 1 then
      printf "%s.%s.%s[%d:0]: ", pname, rname, fname, bitWid-1
    else
      printf "%s.%s.%s: ", pname, rname, fname
    end
    cell = o/4
    res = rd(a[cell],bitoff,bitWid)
    if not $options[:dec] then
      if res >= 10
        print "0x"
      end
      puts res.to_s(16)
    else 
      puts res
    end
  end
end

def regwalk(x, a)
  rblock = x.xpath('registers/register');
  rblock.each do |r|
    reg = r.xpath('name')
    off = r.xpath('addressOffset')
    offset = off.text.to_i(16)
    regfieldwalk(x,r,a,offset)
  end
end

$options = {}
$options[:verbose] = false
$options[:svd] = ""
$options[:skiplist] = []
$options[:onlylist] = []
$options[:logdir] = "."
$options[:dec] = false

OptionParser.new do |opts|
  opts.banner = "Usage: logs2dump.rb [$options]"
  opts.on("-l", "--list", 'List sheets') do
    $options[:list] = true
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

  opts.on("-L", "--logdir=LOGDIR", 'where logfiles are located') do |x|
    $options[:logdir] = x
  end

  opts.on("-D", "--dec", 'dump is dec') do
    $options[:dec] = true
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

curr = Dir.pwd
Dir.chdir($options[:logdir])

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
    asize = bsize.text.to_i(16)    
    psize = ((asize[0] + 3) / 4)     # 4 bytes per x/x read
  else
    psize = 256
  end

  f = File.open(name.text + ".log", "r");
  a = Array.new
  if f then
    slurp(f,a) # get the contents
    # now we have the contents for this periph
    # we walk the registers in the perip
    regwalk(x, a)
    f.close
  else
    p "cannot open" + name.text + ".log"
  end
end

Dir.chdir(curr)
