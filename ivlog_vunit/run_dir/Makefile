all:
	iverilog -I../ -g2012 -o vw_vunit.out ../vw_ivlog_vunit_pkg.sv ../examples/tb_example.sv
	vvp vw_vunit.out
