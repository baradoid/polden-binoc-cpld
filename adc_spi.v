module adcSpi (
	input CLK_10MHZ,
	input start,
	input spiHalfClock,
	
	output ENC1_SCK, ENC2_SCK,
	input ENC1_MISO, ENC2_MISO,	
	
	output reg [10:0] adc_data
);

//// sync SCK to the FPGA clock using a 3-bits shift register
//reg [2:0] SCKr;  always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
//wire SCK_PE = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
//wire SCK_NE = (SCKr[2:1]==2'b10);  // and falling edges
//
//always @(posedge spiHalfClock) begin	
//	ENC_CLK[1:0] <= {ENC_CLK[0],~ENC_CLK[0]};		
//			
//	if(ENC_CLK[1:0] == 2'b10) begin
//		enc1_data[12:0] <= {enc1_data[11:0], ENC1_MISO};
//		enc2_data[12:0] <= {enc2_data[11:0], ENC2_MISO};
//	end	
//end
//

endmodule
