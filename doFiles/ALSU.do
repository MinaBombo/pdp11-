# Create library
vlib work


# Compile and load
vcom -work work ./vhdl/components/fullAdder.vhd
vcom -work work ./vhdl/components/nBitsFullAdder.vhd
vcom -work work ./vhdl/packages/LAO.vhd
vcom -work work ./vhdl/modules/ALSU.vhd
vsim ALSU
radix binary

# Open View windows
view structure
view signals
view wave


# Set up waves to show
add wave /*
property wave -radix hexadecimal /*


# Test Cases:
# F = FFFF+1 
force -deposit A   16#FFFF 0  
force -deposit B   1       0  
force -deposit Cin 0       0
force -deposit sel 00001   0
run 35

# F = FFFF+1+1
force -deposit A   16#FFFF 0  
force -deposit B   1       0  
force -deposit Cin 1       0
force -deposit sel 00010   0
run 35

# F = 0-1 
force -deposit A   0     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 00011 0
run 35

# F = 0-1-1
force -deposit A   0     0  
force -deposit B   1     0  
force -deposit Cin 1     0 
force -deposit sel 00100 0
run 35

# F = 1 AND 1
force -deposit A   1     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 00101 0
run 35

# F = 1 OR 0
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 00110 0
run 35

# F = 1 XOR 1
force -deposit A   1     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 00111 0
run 35

# F = 1 BIC 0
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01000 0
run 35

# F = 0 CMP 1
force -deposit A   0     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 01001 0
run 35

# F = A++
force -deposit A   0     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01010 0
run 35

# F = A--
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01011 0
run 35

# F = !A
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01100 0
run 35

# F = A >> 1
force -deposit A   10    0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01101 0
run 35

# F = A ror
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01110 0
run 35

# F =  A rrc
force -deposit A   1     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 01111 0
run 35

# F = A ASR
force -deposit A   1     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 10000 0
run 35

# F = A << 1
force -deposit A   10    0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 10001 0
run 35

# F = A rol 
force -deposit A   1     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 10010 0
run 35

# F = A rlc
force -deposit A   1     0  
force -deposit B   1     0  
force -deposit Cin 0     0 
force -deposit sel 10011 0
run 35

# F = A+=2
force -deposit A   0     0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 10100 0
run 35

# F = A-=2
force -deposit A   10    0  
force -deposit B   0     0  
force -deposit Cin 0     0 
force -deposit sel 10101 0
run 35