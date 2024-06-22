transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Cristiano/OneDrive/Personal/11.\ Electronics/Obsonet_Wireless/GitHub/obsonet-wireless/hardware/quartus20 {C:/Users/Cristiano/OneDrive/Personal/11. Electronics/Obsonet_Wireless/GitHub/obsonet-wireless/hardware/quartus20/obsonetw.v}
vcom -93 -work work {C:/Users/Cristiano/OneDrive/Personal/11. Electronics/Obsonet_Wireless/GitHub/obsonet-wireless/hardware/quartus20/uart.vhd}
vcom -93 -work work {C:/Users/Cristiano/OneDrive/Personal/11. Electronics/Obsonet_Wireless/GitHub/obsonet-wireless/hardware/quartus20/fifo.vhd}
vcom -93 -work work {C:/Users/Cristiano/OneDrive/Personal/11. Electronics/Obsonet_Wireless/GitHub/obsonet-wireless/hardware/quartus20/wifi.vhd}

