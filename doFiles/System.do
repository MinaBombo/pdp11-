vcom vhdl/packages/*.vhd  vhdl/components/*.vhd vhdl/modules/*.vhd vhdl/system.vhd
vsim work.system
add wave -position insertpoint sim:/system/*
property wave -radix hexadecimal /system/*
mem load -filltype value -filldata 0 -fillradix hexadecimal -skip 0 /system/ram_component/ram_memory
mem load -filltype value -filldata 5630 -fillradix hexadecimal /system/ram_component/ram_memory(0)
mem load -filltype value -filldata 000F -fillradix hexadecimal /system/ram_component/ram_memory(1)
mem load -filltype value -filldata 5672 -fillradix hexadecimal /system/ram_component/ram_memory(2)
mem load -filltype value -filldata 0011 -fillradix hexadecimal /system/ram_component/ram_memory(3)
mem load -filltype value -filldata 0E32 -fillradix hexadecimal /system/ram_component/ram_memory(4)
mem load -filltype value -filldata 000F -fillradix hexadecimal /system/ram_component/ram_memory(5)
mem load -filltype value -filldata 0011 -fillradix hexadecimal /system/ram_component/ram_memory(6)
mem load -filltype value -filldata D800 -fillradix hexadecimal /system/ram_component/ram_memory(7)
mem load -filltype value -filldata 000A -fillradix hexadecimal /system/ram_component/ram_memory(15)
mem load -filltype value -filldata 0011 -fillradix hexadecimal /system/ram_component/ram_memory(17)
force -freeze sim:/system/i_clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/system/i_reset 1 0
run 50
force -freeze sim:/system/i_reset 0 0
run 10000
