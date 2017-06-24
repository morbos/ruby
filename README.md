A repository for some Ruby programs

1) A sudoku solver.
2) svd2gdb 
This program is for embedded developers whose target CPU is described
by a .svd file. When debugging such a target, sometimes its useful to
take memory dumps in gdb before and after a change or, in my case,
reference code from the vendor and then my translation. We can dump
the reference code and then the translation, this then offers a
structured avenue to perform diffs. The results look like this:

set pagination off

set logging file DAC1.log

set logging on

x/256x 0x40007400

set logging off

set logging file DMA1.log

set logging on

x/256x 0x40020000

set logging off

set logging file DMA2.log

set logging on

x/256x 0x40020400

etc

So in gdb, you just source the file the script generates. (a script
generating a script).

This Ruby script needs the nokogiri gem.

gem install nokogiri

You might need Ruby dev headers if not so installed:

apt install ruby-dev



