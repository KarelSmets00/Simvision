# SimVision Command Script (Wed Dec 02 07:27:18 PM CET 2020)
#
# Version 19.03.s013
#
# You can restore this configuration with:
#
#     simvision -input crashrecovery.tcl
#  or simvision -input crashrecovery.tcl database1 database2 ...
#


#
# Preferences
#
preferences set toolbar-Standard-WatchWindow {
  usual
  shown 0
}
preferences set plugin-enable-svdatabrowser-new 1
preferences set toolbar-Windows-WatchWindow {
  usual
  shown 0
}
preferences set toolbar-Standard-Console {
  usual
  position -pos 1
}
preferences set toolbar-Search-Console {
  usual
  position -pos 2
}
preferences set toolbar-Standard-WaveWindow {
  usual
  position -pos 1
}
preferences set plugin-enable-groupscope 0
preferences set plugin-enable-interleaveandcompare 0
preferences set plugin-enable-waveformfrequencyplot 0
preferences set toolbar-SimControl-WatchWindow {
  usual
  shown 0
}
preferences set toolbar-TimeSearch-WatchWindow {
  usual
  shown 0
}

#
# PPE data
#
array set dbNames ""
set dbNames(realName1) [database require waves -hints {
	file ./waves.shm/waves.trn
	file /users/students/r0763954/Documents/EAGLE2/Simvision/EAGLE2_verilog/waves.shm/waves.trn
}]

#
# Mnemonic Maps
#
mmap new  -reuse -name {Boolean as Logic} -radix %b -contents {{%c=FALSE -edgepriority 1 -shape low}
{%c=TRUE -edgepriority 1 -shape high}}
mmap new  -reuse -name {Example Map} -radix %x -contents {{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}}

#
# Design Browser windows
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 730x500+261+33}] != ""} {
    window geometry "Design Browser 1" 730x500+261+33
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set -scope [subst  {$dbNames(realName1)::[format {toplevel}]} ]
browser set \
    -signalsort name
browser yview see [subst  {$dbNames(realName1)::[format {toplevel}]} ]
browser timecontrol set -lock 0

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1024x665+-10+20}] != ""} {
    window geometry "Waveform 1" 1024x665+-10+20
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ms \
    -valuewidth 75
waveform baseline set -time 0

set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.clk}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.data_go}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.freq_rdy}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.freq_set_up_down}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.freq_optimum}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {toplevel.freq[19:0]}]}
	} ]]

waveform xview limits 0 0.000002ms

#
# Waveform Window Links
#

#
# Console windows
#
console set -windowname Console
window geometry Console 730x483+128+142

#
# Layout selection
#

