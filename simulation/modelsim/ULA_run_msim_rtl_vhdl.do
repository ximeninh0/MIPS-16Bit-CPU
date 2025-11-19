transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {C:/Users/23012419/MIPS-16Bit-CPU/REG.vhd}
vcom -2008 -work work {C:/Users/23012419/MIPS-16Bit-CPU/CONSTANTS_PACKAGE.vhd}
vcom -2008 -work work {C:/Users/23012419/MIPS-16Bit-CPU/BUFFER_TRI.vhd}
vcom -2008 -work work {C:/Users/23012419/MIPS-16Bit-CPU/CPU_PACKAGE.vhd}
vcom -2008 -work work {C:/Users/23012419/MIPS-16Bit-CPU/REG_BANK.vhd}

