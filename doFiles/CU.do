quit -sim
vcom vhdl/components/*.vhd vhdl/modules/CU.vhd
vsim work.cu
add wave -position insertpoint sim:/cu/*
property wave -radix hexadecimal /cu/*
force -freeze sim:/cu/i_clk 1 0, 0 {25 ps} -r 50
force -freeze sim:/cu/i_reset 1 0
force -freeze sim:/cu/i_flag 00 0
#Add R0,R1
force -freeze sim:/cu/i_ir 16'h0802 0
run
force -freeze sim:/cu/i_reset 0 0
run
run
run
#Mov R1,R2
force -freeze sim:/cu/i_ir 16'h0044 0
run
run
run
#Add(R1)+,R2
force -freeze sim:/cu/i_ir 16'h0A44 0
run
run
run
run
run
#INC R1
force -freeze sim:/cu/i_ir 16'h5042 0
run
run
run
#INC (R1)+
force -freeze sim:/cu/i_ir 16'h5252 0
run
run
run
run
run
#RTS
force -freeze sim:/cu/i_ir 16'hF800 0
run
run
run
#JSR
force -freeze sim:/cu/i_ir 16'hF000 0
run
run
run
run