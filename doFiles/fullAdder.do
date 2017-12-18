# Create library
vlib work

# Compile and load
vcom -work work ./vhdl/components/fullAdder.vhd
vsim fullAdder

# Open View windows
view structure
view signals
view wave

# Set up waves to show
add wave -noupdate -divider -height 1 
add wave  A
add wave  B
add wave  Cin
add wave -noupdate -divider -height 1  
add wave  F
add wave  Cout

# Test cases
force -deposit A 0 0  
force -deposit B 0 0  
force -deposit Cin 0 0 

force -deposit A 0 50  
force -deposit B 1 50  
force -deposit Cin 0 50

force -deposit A 1 100  
force -deposit B 0 100  
force -deposit Cin 0 100 

force -deposit A 1 150   
force -deposit B 1 150  
force -deposit Cin 0 150 

force -deposit A 0 200  
force -deposit B 0 200  
force -deposit Cin 1 200 

force -deposit A 0 250  
force -deposit B 1 250  
force -deposit Cin 1 250 

force -deposit A 1 300  
force -deposit B 0 300  
force -deposit Cin 1 300 

force -deposit A 1 350   
force -deposit B 1 350 
force -deposit Cin 1 350 

# Run
run 400
