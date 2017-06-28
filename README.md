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


3) logs2dump
This program is a corollary to svd2gdb where it takes in the same svd
file and also a path to where the log files emitted by gdb are
stored. Subsequently, it will emit fields as so, looking at only the
ADC as an example:

./logs2dump.rb -s STM32L4x2.svd -O ADC -L /tmp

ADC.ISR.JQOVF: 0

ADC.ISR.AWD3: 0

ADC.ISR.AWD2: 0

ADC.ISR.AWD1: 0

ADC.ISR.JEOS: 0

ADC.ISR.JEOC: 0

ADC.ISR.OVR: 0

ADC.ISR.EOS: 0

ADC.ISR.EOC: 0

ADC.ISR.EOSMP: 1

ADC.ISR.ADRDY: 1

ADC.IER.JQOVFIE: 0

ADC.IER.AWD3IE: 0

ADC.IER.AWD2IE: 0

ADC.IER.AWD1IE: 0

ADC.IER.JEOSIE: 0

ADC.IER.JEOCIE: 0

ADC.IER.OVRIE: 1

ADC.IER.EOSIE: 0

ADC.IER.EOCIE: 0

ADC.IER.EOSMPIE: 0

ADC.IER.ADRDYIE: 0

ADC.CR.ADCAL: 0

ADC.CR.ADCALDIF: 0

ADC.CR.DEEPPWD: 0

ADC.CR.ADVREGEN: 1

ADC.CR.JADSTP: 0

ADC.CR.ADSTP: 0

ADC.CR.JADSTART: 0

ADC.CR.ADSTART: 0

ADC.CR.ADDIS: 0

ADC.CR.ADEN: 1

etc
