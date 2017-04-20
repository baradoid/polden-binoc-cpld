## Generated SDC file "golden_top.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version"

## DATE    "Thu Apr 20 13:46:09 2017"

##
## DEVICE  "5M570ZF256C4"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {bv_contr_inst|comb_8|altufm_altufm_parallel_j1n_component|maxii_ufm_block1|osc} -period 181.818 -waveform { 0.000 90.909 } [get_pins {bv_contr_inst|comb_8|altufm_altufm_parallel_j1n_component|maxii_ufm_block1|osc}]
create_clock -name {CLK_SE_AR} -period 100.000 -waveform { 0.000 50.000 } [get_ports {CLK_SE_AR}]
#create_clock -name {dallas18b20Ctrl:dallas18b20Ctrl_inst|oneWireClock} -period 1.000 -waveform { 0.000 0.500 } [get_registers {dallas18b20Ctrl:dallas18b20Ctrl_inst|oneWireClock}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

