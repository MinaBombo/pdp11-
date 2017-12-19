# Create library
vlib work


# Compile and load
vcom vhdl/packages/*.vhd  
vcom vhdl/components/*.vhd 
vcom vhdl/modules/*.vhd 
vhdl/system.vhd
vsim work.system


# Open View windows
view structure
view signals
view wave


# Changing wave view to hexdec
property wave -radix hexadecimal /system/*


# Initialize ram memory
mem load -i t2.mem /system/ram_component/ram_memory


# Run
run 10000

