# Create library
vlib work

# Compile and load
vcom -work work ./vhdl/components/nBitsFullAdder.vhd
vsim nBitsFullAdder

# Open View windows
view structure
view signals
view wave

# Set up waves to show
add wave -noupdate -divider -height 16 
add wave  A
add wave  B
add wave -noupdate -divider -height 1 
add wave  Cin
add wave -noupdate -divider -height 16  
add wave  F
add wave -noupdate -divider -height 1 
add wave  Cout

# Changing wave view to hexdec
property wave -radix hexadecimal /nBitsFullAdder/A
property wave -radix hexadecimal /nBitsFullAdder/B
property wave -radix hexadecimal /nBitsFullAdder/F

# Test cases
# F = A
force -deposit A 16#0F0F 0  
force -deposit B 16#0 0  
force -deposit Cin 0 0 

# F = A+B
force -deposit A 16#0F0F 50  
force -deposit B 16#1 50  
force -deposit Cin 0 50

# F = A+B
force -deposit A 16#FFFF 100  
force -deposit B 16#1 100  
force -deposit Cin 0 100 

# F = A+1
force -deposit A 16#0F0E 150  
force -deposit B 16#0 150  
force -deposit Cin 1 150 

# F = A+B+1
force -deposit A 16#FFFF 200  
force -deposit B 16#1 200  
force -deposit Cin 1 200 

# Run
run 250
