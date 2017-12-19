vcom vhdl/packages/*.vhd  vhdl/components/*.vhd vhdl/modules/*.vhd vhdl/system.vhd
vsim work.system
add wave -position insertpoint sim:/system/*
property wave -radix hexadecimal /system/*
mem load -filltype value -filldata 0 -fillradix hexadecimal -skip 0 /system/ram_component/ram_memory
mem load -filltype value -filldata 0682 -fillradix hexadecimal /system/ram_component/ram_memory(0)
mem load -filltype value -filldata 000F -fillradix hexadecimal /system/ram_component/ram_memory(1)
mem load -filltype value -filldata 5842 -fillradix hexadecimal /system/ram_component/ram_memory(2)
mem load -filltype value -filldata B7FE -fillradix hexadecimal /system/ram_component/ram_memory(3)
mem load -filltype value -filldata 5042 -fillradix hexadecimal /system/ram_component/ram_memory(4)
mem load -filltype value -filldata 0074 -fillradix hexadecimal /system/ram_component/ram_memory(5)
mem load -filltype value -filldata 0014 -fillradix hexadecimal /system/ram_component/ram_memory(6)
mem load -filltype value -filldata D800 -fillradix hexadecimal /system/ram_component/ram_memory(7)
force -freeze sim:/system/i_clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/system/i_reset 1 0
run 50
force -freeze sim:/system/i_reset 0 0
force -freeze sim:/system/sig_cu_sp_in 1 0
force -freeze sim:/system/data_bus 16'h00000700 0
run 50
noforce sim:/system/data_bus
noforce sim:/system/sig_cu_sp_in
run 30000
