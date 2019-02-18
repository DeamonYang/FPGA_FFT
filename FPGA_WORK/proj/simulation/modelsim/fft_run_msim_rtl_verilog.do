transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl/fft.v}
vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl/butterfly_ra2.v}
vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/ip {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/ip/ram128.v}
vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/rtl/butterfly_ra2_seri.v}
vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/ip {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/ip/wnp.v}

vlog -vlog01compat -work work +incdir+G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/proj/../testbench {G:/FPWG_WORK/FPGA_W/FFT_S1/FFT_20180922/proj/../testbench/fft_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  fft_tb

add wave *
view structure
view signals
run -all
