# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb.clk
lappend all_signals tb.rst
lappend all_signals tb.up_vld
lappend all_signals tb.up_data
lappend all_signals tb.down_vld
lappend all_signals tb.down_data

lappend all_signals tb.dut.vld_1
lappend all_signals tb.dut.arg_1
lappend all_signals tb.dut.mul_1

lappend all_signals tb.comparison_moment
lappend all_signals tb.down_data_compared
lappend all_signals tb.down_data_expected

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
