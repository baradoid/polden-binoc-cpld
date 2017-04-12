 
 module dallas18b20Ctrl(
input CLK_10MHZ,
input start,
input oneWirePinIn,
output oneWirePinOut,
output reg [15:0] temperature,
output reg [23:0] data
);
reg oneWireClock=0, oneWireReset=0, oneWireRead=0, oneWireWrite=0;


reg[7:0] bufIn;
wire [7:0] byteOut;
reg [3:0] dataInd = 0;
wire busy;
reg busyL;
integer oneWireDelay = 0;


integer clockOneWireDivider = 0;

wire noBusy = (busy==0)&&(busyL==0);
wire startBusy = (busy==1)&&(busyL==0);
wire endBusy = (busy==0)&&(busyL==1);
		
//assign BGPIO[32] = oneWireClock;
//assign BGPIO[33] = busy;


parameter idleState=0;
parameter oneWireResetState=1;
parameter oneWireSkipRomCmd=2; 
parameter readScrPadCmdState=3;
parameter readScrPadDataState=4; 
parameter oneWireWriteSPCmd=7;
parameter oneWireWriteSPData=8;
parameter reset2ndState=9;
parameter skipRomCmd2ndState=10;
parameter convertCmdState=11;
parameter waitConvertOkState=12;
parameter reset3ndState=13;
parameter skipRomCmd3ndState=14;
parameter convertCmdState1=15;
//typedef enum logic [2:0]{ oneWireIdleState, oneWireResetState, oneWireSkipRomCmd, oneWireReadScrPadCmd, oneWireReadScrPad, oneWireConvertCmd, oneWireWaitConvertOk} oneWireState_e;
//oneWireState_e ows = oneWireIdleState;
reg [3:0] oneWireState_e = idleState;

one_wire(
 .clk(oneWireClock),
 .reset(oneWireReset),
 .wire_out(oneWirePinOut),
 .wire_in(oneWirePinIn),
 .in_byte(bufIn[7:0]),
 .out_byte(byteOut[7:0]),
 .read_byte(oneWireRead),
 .write_byte(oneWireWrite),
 .busy(busy)
);


always @(posedge CLK_10MHZ) begin
		
	if(clockOneWireDivider == 59) begin
		clockOneWireDivider <= 0;	
		oneWireClock <= 1;
	end
	else begin
		clockOneWireDivider <= clockOneWireDivider + 1;					
		oneWireClock <= 0;
	end
	
	busyL <= busy;
	
	case(oneWireState_e)
	idleState: begin
			if(start) begin			
				oneWireState_e <= oneWireResetState;								
			end					
		end
	oneWireResetState: begin
			if(noBusy) begin
				oneWireReset <= 1;		
			end
			if(startBusy) begin
				oneWireReset <= 0;											
			end
			if(endBusy) begin
				oneWireState_e <= oneWireSkipRomCmd;	
				//oneWireState_e <= oneWireIdleState;					
				//bufIn <= 8'hCC;
			end	
	end
	oneWireSkipRomCmd: begin
		if(noBusy) begin
			oneWireWrite <= 1;		
			bufIn <= 8'hCC;
		end
				
		if(startBusy) begin
			oneWireWrite <= 0;	
		end
		if(endBusy) begin
			oneWireState_e <= readScrPadCmdState;		
			//oneWireState_e <= oneWireWriteSPCmd;		
			//oneWireState_e <= oneWireIdleState;	
			//bufIn <= 8'h4E;			
		end
		
	end
	
	oneWireWriteSPCmd: begin		
		if(noBusy) begin
			oneWireWrite <= 1;		
			bufIn <= 8'h4E;
		end
		if(startBusy) begin
			oneWireWrite <= 0;	
		end
		if(endBusy) begin
			oneWireState_e <= oneWireWriteSPData;
			dataInd <= 0;
			//oneWireByteBufOut <= 8'hdd;			
			//oneWireState_e <= oneWireIdleState;					
		end	
	end
	
	oneWireWriteSPData: begin
		if(noBusy) begin						
			oneWireWrite <= 1;			
			case(dataInd)
				0: bufIn <= 8'hbe;			
				1: bufIn <= 8'hef;			
				2: bufIn <= 8'h1F;				
			endcase			
		end
		if(startBusy) begin
			oneWireWrite <= 0;	
			dataInd <= dataInd + 1;
		end
		if(endBusy) begin					
//			if(oneWireDataCnt == 1) begin
//				temperature[7:0] <= 8'hde;										
//			end
//			if(oneWireDataCnt == 2) begin
//				temperature[15:8] <= 8'hbc;										
//			end

			case(dataInd)
				3: oneWireState_e <= reset2ndState;	//oneWireState_e <= readScrPadCmdState; //
			endcase
			
		end
	end
	
	reset2ndState: begin
		if(noBusy) begin
			oneWireReset <= 1;		
		end
		if(startBusy) begin
			oneWireReset <= 0;											
		end
		if(endBusy) begin
			oneWireState_e <= skipRomCmd2ndState;	
				//oneWireState_e <= oneWireIdleState;		
			//oneWireByteBufOut <= 8'hCC;			
		end		
	end
	
	skipRomCmd2ndState: begin
		if(noBusy) begin
			oneWireWrite <= 1;		
			bufIn <= 8'hCC;
		end
				
		if(startBusy) begin
			oneWireWrite <= 0;	
		end
		if(endBusy) begin
			oneWireState_e <= convertCmdState;		
			//oneWireState_e <= oneWireIdleState;					
			//oneWireState_e <= readScrPadCmdState;
		end
	end
	
	readScrPadCmdState: begin
		if(noBusy) begin
			oneWireWrite <= 1;		
			bufIn <= 8'hBE;
		end
		if(startBusy) begin
			oneWireWrite <= 0;							
		end
		if(endBusy) begin			
			dataInd <= 0;
			oneWireState_e <= readScrPadDataState;		
			//oneWireState_e <= oneWireIdleState;
		end	
	end	
	readScrPadDataState: begin
		if(noBusy) begin
			oneWireRead <= 1;					
		end
		if(startBusy) begin
			oneWireRead <= 0;														
		end
		if(endBusy) begin						
			dataInd <= dataInd + 1;		
			case(dataInd) 
				0: temperature[7:0] <= byteOut;	
				1: temperature[15:8] <= byteOut;
				//2: temperature[7:0] <= oneWireByteBufOut; //8'hde;	
				//3: temperature[15:8] <= oneWireByteBufOut; //8'hbc;
				2:	data[7:0] <= byteOut; 
				3: data[15:8] <= byteOut;
				4: begin 
					data[23:16] <= byteOut;				
					oneWireState_e <= reset2ndState;						
					end
			   9: begin
					//
					//oneWireState_e <= idleState;						
					//oneWireState_e <= reset2ndState;						
					end
				default: ;
			endcase				
		end
	end
	
	
	convertCmdState: begin
		if(noBusy) begin
			oneWireWrite <= 1;		
			bufIn <= 8'h44;			
		end
		if(startBusy) begin
			oneWireWrite <= 0;	
		end
		if(endBusy) begin
			oneWireState_e <= idleState;		
			//if(oneWirePinIn == 1) begin
				//oneWireState_e <= oneWireResetState;	
			//end
		end
	end
	
//	reset3ndState: begin
//		if(noBusy) begin
//			oneWireReset <= 1;		
//		end
//		if(startBusy) begin
//			oneWireReset <= 0;											
//		end
//		if(endBusy) begin
//			oneWireState_e <= skipRomCmd3ndState;	
//				//oneWireState_e <= oneWireIdleState;		
//			//oneWireByteBufOut <= 8'hCC;			
//		end		
//	end
	
//	skipRomCmd3ndState: begin
//		if(noBusy) begin
//			oneWireWrite <= 1;		
//			bufIn <= 8'hCC;
//		end
//				
//		if(startBusy) begin
//			oneWireWrite <= 0;	
//		end
//		if(endBusy) begin
//			oneWireState_e <= convertCmdState1;		
//			//oneWireState_e <= oneWireIdleState;					
//			//oneWireState_e <= readScrPadCmdState;
//		end
//	end
	
//	convertCmdState1: begin
//		if(noBusy) begin
//			oneWireWrite <= 1;		
//			bufIn <= 8'h44;			
//		end
//		if(startBusy) begin
//			oneWireWrite <= 0;	
//		end
//		if(endBusy) begin
//			oneWireState_e <= idleState;		
//			//if(oneWirePinIn == 1) begin
//				//oneWireState_e <= oneWireResetState;	
//			//end
//		end
//	end
//	
	
//	waitConvertOkState: begin
//		if(noBusy) begin
//			oneWireRead <= 1;					
//		end
//		if(startBusy) begin
//			oneWireRead <= 0;	
//	
//		end		
//		if(endBusy) begin
//			if(oneWireByteBufOut) begin
//				oneWireState_e <= readScrPadCmdState;				
//			end				
//		end
//	end
	



	default: oneWireState_e <= idleState;		
	
	endcase

end
 
endmodule