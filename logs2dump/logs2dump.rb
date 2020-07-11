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
  pat = /.*0x\h{8}.*:(.*)$/
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
def cvert(s, op)
  return nil if s.text == ""
  if s.text[0..1] == "0x" and op == :to_i
    op = :hex
  end
  eval("s.text.#{op}")
end
def regfieldwalk(x, r, a, o, override, cname, coff)
  pname = override
  rname = r.xpath('name').text
  dim = cvert(r.xpath('dim'), :to_i)
  dimInc = cvert(r.xpath('dimIncrement'), :hex)
  dimIndex = r.xpath('dimIndex').text
  desc = r.xpath('description').text
  if coff
    o += coff
  end
#  printf "off 0x%08x\n", o
  dim = 1 if not dim
  for i in 0...dim do
    fblock = r.xpath('fields/field');
    fblock.each do |f|
      fname = f.xpath('name').text
      bitoff = f.xpath('bitOffset').text.to_i
      bitWid = f.xpath('bitWidth').text.to_i
#      p bitoff.text.to_i, bitWid.text.to_i
      if bitoff == 0 and bitWid == 0
        lsb = f.xpath('lsb').text.to_i
        msb = f.xpath('msb').text.to_i
        bitWid = (msb - lsb) + 1
        bitoff = lsb
      end
#      bitWid = f.xpath('bitWidth').text.to_i
      if rname.include?('[')
        rn = sprintf rname, i.to_s
      else
        rn = rname
      end
      if bitWid > 1 then
        if cname
          printf "%s.%s.%s.%s[%d:0]: ", pname, cname, rn, fname, bitWid-1
        else
          printf "%s.%s.%s[%d:0]: ", pname, rn, fname, bitWid-1
        end
      else
        if cname
          printf "%s.%s.%s.%s: ", pname, cname, rn, fname
        else
          printf "%s.%s.%s: ", pname, rn, fname
        end
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
    if dimInc
      o += dimInc
    end
  end
end

def regwalk(x, a, override, cname, coff)
  x.each do |r|
    case r.name
    when "register"
      reg = r.xpath('name')
      off = r.xpath('addressOffset')
      offset = off.text.to_i(16)
      regfieldwalk(x, r, a, offset, override, cname, coff)
    when "cluster"
      dim = cvert(r.xpath('dim'), :to_i)
      dimInc = cvert(r.xpath('dimIncrement'), :hex)
      name = r.xpath('name').text
      desc = r.xpath('description').text
      addrOffset = cvert(r.xpath('addressOffset'),:hex)
      if name.include?('[')
        for i in 0...dim do
          cname = sprintf name, i.to_s
          regwalk(r.xpath('*'), a, override, cname, addrOffset + (i * dimInc))
        end
        cname = nil
        coff = nil
      else
        regwalk(r.xpath('*'), a, override, name, addrOffset)
      end
    end
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

# 2 pass now.
# pass 1 add all periph's to a hash keyed by name
spot = Hash.new
per.each do |x|
  name = x.xpath('name')
  spot[name.text] = x
end

# pass 2 if the periph is 'derivedFrom' pull its defn from the hash setup
# in pass 1.
per.each do |x|
  name = x.xpath('name')

  if skiplist && skiplist[name.text.upcase] then # user did not want this in the dump
    next
  end
  if onlylist && (not onlylist[name.text.upcase]) then # user wants specific peripherals
    next
  end

  e = x.attributes['derivedFrom']
  if e != nil
    x = spot[e.value]
  end
  override = name.text

  f = File.open(name.text + ".log", "r");
  a = Array.new
  if f then
    slurp(f,a) # get the contents
    # now we have the contents for this periph
    # we walk the registers in the perip
    if a == []
      p "slurp failed"
      exit
    end
#    a.each_with_index do |x,i|
#      printf "0x%08x: %08x\n", i*4, x
#    end
    regwalk(x.xpath('registers/*'), a, override, nil, nil)
    f.close
  else
    p "cannot open" + name.text + ".log"
  end
end

Dir.chdir(curr)
