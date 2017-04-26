module encoderSpi (
	input CLK_10MHZ,
	input start,
	input spiHalfClock,
	
	output ENC1_SCK, ENC2_SCK,
	input ENC1_MISO, ENC2_MISO,

	output reg [12:0] enc1_data,
	output reg [12:0] enc2_data
);

reg ENC_CLK = 1'b1;

assign ENC1_SCK = ENC_CLK;
assign ENC2_SCK = ENC_CLK;

//wire SCK_pe = (ENC_CLK && ~ENC_CLK);
//wire SCK_ne = (ENC_CLK && ~ENC_CLK);
//always @(posedge CLK_10MHZ) begin

//end
reg state = 0;
reg [3:0] bitCnt = 4'h0;


always @(posedge CLK_10MHZ) begin	
			
	case(state)
		0: begin
		if(start)
			state <= 1;	
			bitCnt <= 4'h0;
			ENC_CLK <= 1'b1;
		end
		
		1: begin			
			if(spiHalfClock) begin
				ENC_CLK <= ~ENC_CLK;		
				if(ENC_CLK == 1'b1) begin
					enc1_data[12:0] <= {enc1_data[11:0], ENC1_MISO};
					enc2_data[12:0] <= {enc2_data[11:0], ENC2_MISO};
					bitCnt <= bitCnt + 4'h1;
				end	
			end
			if(bitCnt == 4'd13) begin
				state <= 0;
			end
			
		end
				
	endcase
	
end


endmodule
