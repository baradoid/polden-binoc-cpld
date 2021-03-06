// megafunction wizard: %ALTUFM_PARALLEL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: ALTUFM_PARALLEL 

// ============================================================
// File Name: altufm.v
// Megafunction Name(s):
// 			ALTUFM_PARALLEL
//
// Simulation Library Files(s):
// 			maxv
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.0.1 Build 232 06/12/2013 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//altufm_parallel ACCESS_MODE="READ_ONLY" CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="MAX V" ERASE_TIME=500000000 LPM_FILE="ufm_init.hex" OSC_FREQUENCY=180000 PROGRAM_TIME=1600000 WIDTH_ADDRESS=9 WIDTH_DATA=16 WIDTH_UFM_ADDRESS=9 addr data_valid dataout nbusy nread
//VERSION_BEGIN 13.0 cbx_a_gray2bin 2013:06:12:18:03:43:SJ cbx_a_graycounter 2013:06:12:18:03:43:SJ cbx_altufm_parallel 2013:06:12:18:03:43:SJ cbx_cycloneii 2013:06:12:18:03:43:SJ cbx_lpm_add_sub 2013:06:12:18:03:43:SJ cbx_lpm_compare 2013:06:12:18:03:43:SJ cbx_lpm_counter 2013:06:12:18:03:43:SJ cbx_lpm_decode 2013:06:12:18:03:43:SJ cbx_lpm_mux 2013:06:12:18:03:43:SJ cbx_maxii 2013:06:12:18:03:43:SJ cbx_mgl 2013:06:12:18:05:10:SJ cbx_stratix 2013:06:12:18:03:43:SJ cbx_stratixii 2013:06:12:18:03:43:SJ cbx_util_mgl 2013:06:12:18:03:43:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = lpm_counter 1 lut 62 maxv_ufm 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"suppress_da_rule_internal=c101;suppress_da_rule_internal=c103;suppress_da_rule_internal=c104;suppress_da_rule_internal=r101;suppress_da_rule_internal=s104;suppress_da_rule_internal=s102"} *)
module  altufm_altufm_parallel_j1n
	( 
	addr,
	data_valid,
	dataout,
	nbusy,
	nread) /* synthesis synthesis_clearbox=2 */;
	input   [8:0]  addr;
	output   data_valid;
	output   [15:0]  dataout;
	output   nbusy;
	input   nread;

	reg	[8:0]	A;
	reg	data_valid_out_reg;
	reg	data_valid_reg;
	reg	deco1_dffe;
	reg	decode_dffe;
	reg	gated_clk1_dffe;
	reg	gated_clk2_dffe;
	reg	real_decode2_dffe;
	reg	real_decode_dffe;
	reg	[15:0]	sipo_dffe;
	wire	[15:0]	wire_tmp_do_d;
	reg	[15:0]	tmp_do;
	wire	[15:0]	wire_tmp_do_ena;
	wire  [4:0]   wire_cntr2_q;
	wire  wire_maxii_ufm_block1_bgpbusy;
	wire  wire_maxii_ufm_block1_drdout;
	wire  wire_maxii_ufm_block1_osc;
	wire  add_en;
	wire  add_load;
	wire  arclk;
	wire  busy_arclk;
	wire  busy_drclk;
	wire  control_mux;
	wire  copy_tmp_decode;
	wire  data_valid_en;
	wire  dly_tmp_decode;
	wire  drdin;
	wire  gated1;
	wire  gated2;
	wire  hold_decode;
	wire  in_read_data_en;
	wire  in_read_drclk;
	wire  in_read_drshft;
	wire  mux_nread;
	wire oscena;
	wire  q0;
	wire  q1;
	wire  q2;
	wire  q3;
	wire  q4;
	wire  read;
	wire  read_op;
	wire  real_decode;
	wire  [8:0]  shiftin;
	wire  [15:0]  sipo_q;
	wire  start_decode;
	wire  start_op;
	wire  stop_op;
	wire  tmp_add_en;
	wire  tmp_add_load;
	wire  tmp_arclk;
	wire  tmp_arclk0;
	wire  tmp_ardin;
	wire  tmp_arshft;
	wire  tmp_data_valid2;
	wire  tmp_decode;
	wire  tmp_drclk;
	wire  tmp_in_read_data_en;
	wire  tmp_in_read_drclk;
	wire  tmp_in_read_drshft;
	wire  tmp_read;
	wire  ufm_arclk;
	wire  ufm_ardin;
	wire  ufm_arshft;
	wire  ufm_bgpbusy;
	wire  ufm_drclk;
	wire  ufm_drdin;
	wire  ufm_drdout;
	wire  ufm_drshft;
	wire  ufm_osc;
	wire  ufm_oscena;
	wire  [8:0]  X_var;
	wire  [8:0]  Y_var;
	wire  [8:0]  Z_var;

	// synopsys translate_off
	initial
		A = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (add_en == 1'b1)   A <= {Z_var};
	// synopsys translate_off
	initial
		data_valid_out_reg = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  data_valid_out_reg <= (data_valid_reg & (~ tmp_decode));
	// synopsys translate_off
	initial
		data_valid_reg = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (data_valid_en == 1'b1)   data_valid_reg <= tmp_data_valid2;
	// synopsys translate_off
	initial
		deco1_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (start_op == 1'b1)   deco1_dffe <= mux_nread;
	// synopsys translate_off
	initial
		decode_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  decode_dffe <= copy_tmp_decode;
	// synopsys translate_off
	initial
		gated_clk1_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  gated_clk1_dffe <= busy_arclk;
	// synopsys translate_off
	initial
		gated_clk2_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  gated_clk2_dffe <= busy_drclk;
	// synopsys translate_off
	initial
		real_decode2_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  real_decode2_dffe <= real_decode_dffe;
	// synopsys translate_off
	initial
		real_decode_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		  real_decode_dffe <= start_decode;
	// synopsys translate_off
	initial
		sipo_dffe = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (in_read_data_en == 1'b1)   sipo_dffe <= {sipo_q[14:0], ufm_drdout};
	// synopsys translate_off
	initial
		tmp_do[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[0:0] == 1'b1)   tmp_do[0:0] <= wire_tmp_do_d[0:0];
	// synopsys translate_off
	initial
		tmp_do[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[1:1] == 1'b1)   tmp_do[1:1] <= wire_tmp_do_d[1:1];
	// synopsys translate_off
	initial
		tmp_do[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[2:2] == 1'b1)   tmp_do[2:2] <= wire_tmp_do_d[2:2];
	// synopsys translate_off
	initial
		tmp_do[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[3:3] == 1'b1)   tmp_do[3:3] <= wire_tmp_do_d[3:3];
	// synopsys translate_off
	initial
		tmp_do[4:4] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[4:4] == 1'b1)   tmp_do[4:4] <= wire_tmp_do_d[4:4];
	// synopsys translate_off
	initial
		tmp_do[5:5] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[5:5] == 1'b1)   tmp_do[5:5] <= wire_tmp_do_d[5:5];
	// synopsys translate_off
	initial
		tmp_do[6:6] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[6:6] == 1'b1)   tmp_do[6:6] <= wire_tmp_do_d[6:6];
	// synopsys translate_off
	initial
		tmp_do[7:7] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[7:7] == 1'b1)   tmp_do[7:7] <= wire_tmp_do_d[7:7];
	// synopsys translate_off
	initial
		tmp_do[8:8] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[8:8] == 1'b1)   tmp_do[8:8] <= wire_tmp_do_d[8:8];
	// synopsys translate_off
	initial
		tmp_do[9:9] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[9:9] == 1'b1)   tmp_do[9:9] <= wire_tmp_do_d[9:9];
	// synopsys translate_off
	initial
		tmp_do[10:10] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[10:10] == 1'b1)   tmp_do[10:10] <= wire_tmp_do_d[10:10];
	// synopsys translate_off
	initial
		tmp_do[11:11] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[11:11] == 1'b1)   tmp_do[11:11] <= wire_tmp_do_d[11:11];
	// synopsys translate_off
	initial
		tmp_do[12:12] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[12:12] == 1'b1)   tmp_do[12:12] <= wire_tmp_do_d[12:12];
	// synopsys translate_off
	initial
		tmp_do[13:13] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[13:13] == 1'b1)   tmp_do[13:13] <= wire_tmp_do_d[13:13];
	// synopsys translate_off
	initial
		tmp_do[14:14] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[14:14] == 1'b1)   tmp_do[14:14] <= wire_tmp_do_d[14:14];
	// synopsys translate_off
	initial
		tmp_do[15:15] = 0;
	// synopsys translate_on
	always @ ( posedge ufm_osc)
		if (wire_tmp_do_ena[15:15] == 1'b1)   tmp_do[15:15] <= wire_tmp_do_d[15:15];
	assign
		wire_tmp_do_d = {sipo_q[15:0]};
	assign
		wire_tmp_do_ena = {16{(data_valid_reg & (~ tmp_decode))}};
	lpm_counter   cntr2
	( 
	.clk_en(tmp_decode),
	.clock(ufm_osc),
	.cout(),
	.eq(),
	.q(wire_cntr2_q)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aclr(1'b0),
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.data({5{1'b0}}),
	.sclr(1'b0),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr2.lpm_direction = "UP",
		cntr2.lpm_modulus = 28,
		cntr2.lpm_port_updown = "PORT_UNUSED",
		cntr2.lpm_width = 5,
		cntr2.lpm_type = "lpm_counter";
	maxv_ufm   maxii_ufm_block1
	( 
	.arclk(ufm_arclk),
	.ardin(ufm_ardin),
	.arshft(ufm_arshft),
	.bgpbusy(wire_maxii_ufm_block1_bgpbusy),
	.busy(),
	.drclk(ufm_drclk),
	.drdin(ufm_drdin),
	.drdout(wire_maxii_ufm_block1_drdout),
	.drshft(ufm_drshft),
	.osc(wire_maxii_ufm_block1_osc),
	.oscena(ufm_oscena)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.erase(1'b0),
	.program(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.ctrl_bgpbusy(1'b0),
	.devclrn(1'b1),
	.devpor(1'b1),
	.sbdin(1'b0),
	.sbdout()
	// synopsys translate_on
	);
	defparam
		maxii_ufm_block1.address_width = 9,
		maxii_ufm_block1.erase_time = 500000000,
		maxii_ufm_block1.init_file = "ufm_init.hex",
		maxii_ufm_block1.mem1 = 512'h00FFFFFFFFFFFFFF34FF0CFF03FF02FFFFFFFFFF82FFC2FF00FF06FF03FF02FFFFFFFFFFB3FF41FF30FF06FF03FF02FFFFFFFFFF81FFDAFF33FF06FF03FF02FF,
		maxii_ufm_block1.mem10 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem11 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem12 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem13 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem14 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem15 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem16 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem2 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC1FFB5FF00FF00FF,
		maxii_ufm_block1.mem3 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem4 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem5 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem6 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem7 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem8 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.mem9 = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
		maxii_ufm_block1.osc_sim_setting = 180000,
		maxii_ufm_block1.program_time = 1600000,
		maxii_ufm_block1.lpm_type = "maxv_ufm";
	assign
		add_en = (tmp_add_en & read_op),
		add_load = (tmp_add_load & read_op),
		arclk = (tmp_arclk0 & read_op),
		busy_arclk = arclk,
		busy_drclk = in_read_drclk,
		control_mux = (((~ q4) & ((q3 | q2) | q1)) | q4),
		copy_tmp_decode = tmp_decode,
		data_valid = data_valid_out_reg,
		data_valid_en = ((q4 & q3) & q1),
		dataout = tmp_do,
		dly_tmp_decode = decode_dffe,
		drdin = 1'b0,
		gated1 = gated_clk1_dffe,
		gated2 = gated_clk2_dffe,
		hold_decode = ((~ real_decode2_dffe) & real_decode),
		in_read_data_en = (tmp_in_read_data_en & read_op),
		in_read_drclk = (tmp_in_read_drclk & read_op),
		in_read_drshft = (tmp_in_read_drshft & read_op),
		mux_nread = (((~ control_mux) & read) | (control_mux & (~ data_valid_en))),
		nbusy = ((~ dly_tmp_decode) & (~ ufm_bgpbusy)),
		oscena = 1'b1,
		q0 = wire_cntr2_q[0],
		q1 = wire_cntr2_q[1],
		q2 = wire_cntr2_q[2],
		q3 = wire_cntr2_q[3],
		q4 = wire_cntr2_q[4],
		read = (~ nread),
		read_op = tmp_read,
		real_decode = start_decode,
		shiftin = {A[7:0], 1'b0},
		sipo_q = {sipo_dffe[15:0]},
		start_decode = (mux_nread & (~ ufm_bgpbusy)),
		start_op = (hold_decode | stop_op),
		stop_op = ((((q4 & q3) & (~ q2)) & q1) & q0),
		tmp_add_en = ((~ q4) & ((~ q3) | ((~ q2) & (~ q1)))),
		tmp_add_load = (~ ((~ q4) & (((((~ q3) & q2) | ((~ q3) & q0)) | ((~ q3) & q1)) | ((q3 & (~ q2)) & (~ q1))))),
		tmp_arclk = (gated1 & (~ ufm_osc)),
		tmp_arclk0 = ((~ q4) & ((~ q3) | (((~ q2) & (~ q1)) & (~ q0)))),
		tmp_ardin = A[8],
		tmp_arshft = add_en,
		tmp_data_valid2 = (stop_op & read_op),
		tmp_decode = tmp_read,
		tmp_drclk = (gated2 & (~ ufm_osc)),
		tmp_in_read_data_en = (((~ q4) & ((q3 & q2) | (q3 & q1))) | (q4 & (((~ q3) | ((~ q2) & (~ q1))) | (q1 & (~ q0))))),
		tmp_in_read_drclk = (((~ q4) & ((q3 & q2) | (q3 & q1))) | (q4 & (((~ q3) | ((~ q2) & (~ q1))) | (q1 & (~ q0))))),
		tmp_in_read_drshft = (~ (((((~ q4) & q3) & (~ q2)) & q1) & q0)),
		tmp_read = deco1_dffe,
		ufm_arclk = tmp_arclk,
		ufm_ardin = tmp_ardin,
		ufm_arshft = tmp_arshft,
		ufm_bgpbusy = wire_maxii_ufm_block1_bgpbusy,
		ufm_drclk = tmp_drclk,
		ufm_drdin = drdin,
		ufm_drdout = wire_maxii_ufm_block1_drdout,
		ufm_drshft = in_read_drshft,
		ufm_osc = wire_maxii_ufm_block1_osc,
		ufm_oscena = oscena,
		X_var = (shiftin & {9{(~ add_load)}}),
		Y_var = (addr & {9{add_load}}),
		Z_var = (X_var | Y_var);
endmodule //altufm_altufm_parallel_j1n
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module altufm (
	addr,
	nread,
	data_valid,
	dataout,
	nbusy)/* synthesis synthesis_clearbox = 2 */;

	input	[8:0]  addr;
	input	  nread;
	output	  data_valid;
	output	[15:0]  dataout;
	output	  nbusy;

	wire [15:0] sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire [15:0] dataout = sub_wire0[15:0];
	wire  data_valid = sub_wire1;
	wire  nbusy = sub_wire2;

	altufm_altufm_parallel_j1n	altufm_altufm_parallel_j1n_component (
				.nread (nread),
				.addr (addr),
				.dataout (sub_wire0),
				.data_valid (sub_wire1),
				.nbusy (sub_wire2))/* synthesis synthesis_clearbox=2
	 clearbox_macroname = ALTUFM_PARALLEL
	 clearbox_defparam = "access_mode=READ_ONLY;erase_time=500000000;intended_device_family=MAX V;lpm_file=ufm_init.hex;lpm_hint=UNUSED;lpm_type=altufm_parallel;osc_frequency=180000;program_time=1600000;width_address=9;width_data=16;width_ufm_address=9;" */;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "MAX V"
// Retrieval info: PRIVATE: OSC_PORT STRING "OFF"
// Retrieval info: CONSTANT: ACCESS_MODE STRING "READ_ONLY"
// Retrieval info: CONSTANT: ERASE_TIME NUMERIC "500000000"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "MAX V"
// Retrieval info: CONSTANT: LPM_FILE STRING "ufm_init.hex"
// Retrieval info: CONSTANT: LPM_HINT STRING "UNUSED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altufm_parallel"
// Retrieval info: CONSTANT: OSC_FREQUENCY NUMERIC "180000"
// Retrieval info: CONSTANT: PROGRAM_TIME NUMERIC "1600000"
// Retrieval info: CONSTANT: WIDTH_ADDRESS NUMERIC "9"
// Retrieval info: CONSTANT: WIDTH_DATA NUMERIC "16"
// Retrieval info: CONSTANT: WIDTH_UFM_ADDRESS NUMERIC "9"
// Retrieval info: USED_PORT: addr 0 0 9 0 INPUT NODEFVAL "addr[8..0]"
// Retrieval info: CONNECT: @addr 0 0 9 0 addr 0 0 9 0
// Retrieval info: USED_PORT: data_valid 0 0 0 0 OUTPUT NODEFVAL "data_valid"
// Retrieval info: CONNECT: data_valid 0 0 0 0 @data_valid 0 0 0 0
// Retrieval info: USED_PORT: dataout 0 0 16 0 OUTPUT NODEFVAL "dataout[15..0]"
// Retrieval info: CONNECT: dataout 0 0 16 0 @dataout 0 0 16 0
// Retrieval info: USED_PORT: nbusy 0 0 0 0 OUTPUT NODEFVAL "nbusy"
// Retrieval info: CONNECT: nbusy 0 0 0 0 @nbusy 0 0 0 0
// Retrieval info: USED_PORT: nread 0 0 0 0 INPUT NODEFVAL "nread"
// Retrieval info: CONNECT: @nread 0 0 0 0 nread 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm.v TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm.qip TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm.bsf TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm_inst.v TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm_bb.v TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm.inc TRUE TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL altufm.cmp TRUE TRUE
// Retrieval info: LIB_FILE: maxv
