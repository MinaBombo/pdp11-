vcom vhdl/packages/*.vhd  vhdl/components/*.vhd vhdl/modules/*.vhd vhdl/system.vhd
vsim work.system
add wave -position insertpoint sim:/system/*
property wave -radix hexadecimal /system/*
add wave -position 2 sim:/system/sp/*
mem load -filltype value -filldata 0 -fillradix hexadecimal -skip 0 /system/ram_component/ram_memory
mem load -filltype value -filldata 5042 -fillradix hexadecimal /system/ram_component/ram_memory(0)
mem load -filltype value -filldata F008 -fillradix hexadecimal /system/ram_component/ram_memory(1)
mem load -filltype value -filldata 0074 -fillradix hexadecimal /system/ram_component/ram_memory(2)
mem load -filltype value -filldata 0014 -fillradix hexadecimal /system/ram_component/ram_memory(3)
mem load -filltype value -filldata F008 -fillradix hexadecimal /system/ram_component/ram_memory(4)
mem load -filltype value -filldata 0074 -fillradix hexadecimal /system/ram_component/ram_memory(5)
mem load -filltype value -filldata 0020 -fillradix hexadecimal /system/ram_component/ram_memory(6)
mem load -filltype value -filldata D800 -fillradix hexadecimal /system/ram_component/ram_memory(7)
mem load -filltype value -filldata 5042 -fillradix hexadecimal /system/ram_component/ram_memory(8)
mem load -filltype value -filldata 5042 -fillradix hexadecimal /system/ram_component/ram_memory(9)
mem load -filltype value -filldata 5042 -fillradix hexadecimal /system/ram_component/ram_memory(10)
mem load -filltype value -filldata F800 -fillradix hexadecimal /system/ram_component/ram_memory(11)
force -freeze sim:/system/i_clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/system/i_reset 1 0
run 50
force -freeze sim:/system/i_reset 0 0
run 30000
