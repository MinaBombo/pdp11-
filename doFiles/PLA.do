# Create library
vlib work


# Compile and load
vcom -work work ./vhdl/components/PLA.vhd
vsim PLA
radix binary


# Open View windows
view structure
view signals
view wave


# Set up waves to show
add wave /*
property wave -radix decimal /pla/addr


# Test Cases:
# ADD R1, R2
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     10
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     11
run 35

# MOV R1, R2
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       1

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     01
run 35

# ADD (R1)+, R2
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 01
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     10
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     11
run 35


# Add (R1)+, -(R2)
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 01
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     01
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 10
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     10
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     11
run 35

# MOV (R1)+, X(R2)
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       1

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 11
force -deposit cycle     01
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 11
force -deposit cycle     01
run 35

# MOV (R1)+, R2
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       1

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     01
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 00
force -deposit cycle     01
run 35


# INC R1
force -deposit n_ops     01
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     10
run 35

# INC (R1)+
force -deposit n_ops     01
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 01
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 01
force -deposit cycle     10
run 35

# JSR 
force -deposit n_ops     00
force -deposit spec_op   01
force -deposit mov       0
run 35

# ADD R1, -(R2)
force -deposit n_ops     10
force -deposit spec_op   00
force -deposit mov       0

force -deposit dirty_bit 0
force -deposit addr_mode 00
force -deposit cycle     00
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     01
run 35

force -deposit dirty_bit 1
force -deposit addr_mode 10
force -deposit cycle     01
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     10
run 35

force -deposit dirty_bit 0
force -deposit addr_mode 10
force -deposit cycle     11
run 35