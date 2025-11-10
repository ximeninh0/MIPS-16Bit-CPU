transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/AND_COMPONENT.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/OR_COMPONENT.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/COMPARATOR.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/NOT_COMPONENT.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/FULLADDER.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/CPU_PACKAGE.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/RIPPLE_CARRY.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/MULTI_COMPONENT.vhd}
vcom -2008 -work work {C:/Users/guixi/Desktop/CPUv3_6/Projeto_CPU/ULA.vhd}

