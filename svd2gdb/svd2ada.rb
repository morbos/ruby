#!/usr/bin/ruby
require 'nokogiri'
require 'scanf'

#
# given an XML .svd file as input, this ditty works
# through the hierarchy producing a GDB script file.
# This script is of a form that will dump the regs for
# your arch so you can do a before/after register triage.
#

@doc=File.open(ARGV[0]) { |f| Nokogiri::XML(f) }

@per =  @doc.xpath("//peripheral")

puts "set pagination off"
@per.each do |x|
  name = x.xpath('name')
  ba = x.xpath('baseAddress')
  bsize = x.xpath('addressBlock/size');
  if bsize[0] then
    asize = bsize.text.scanf "%x"
    psize = ((asize[0] + 3) / 4)     # 4 bytes per x/x read
  else
    psize = 256
  end
  printf "set logging file %s.log\n",name.text
  puts "set logging on"
  printf "x/%sx %s\n",psize,ba.text
  puts "set logging off"
end





















