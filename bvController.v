module bv_controller (
    input CLK_10MHZ,	
	 input uartRxPin,
	 input uartStartSignal,
	 output uartTxPin,
    output reg[ 7:0] billAccumed = 8'h0,
	 output ufmDataValid,
	 output reg ufmnRead = 1'b1
  );
  
  

async_transmitter #(.ClkFrequency(10000000), .Baud(19200)) TXBV(.clk(CLK_10MHZ), 
																					 .TxD(uartTxPin), 
																					 .TxD_start(uartStart), 
																					 .TxD_data(uartDataReg),
																					 .TxD_busy(uartTxBusy));
																					 
async_receiver #(.ClkFrequency(10000000), .Baud(19200)) RXBV(.clk(CLK_10MHZ), 
																					 .RxD(uartRxPin), 
																					 .RxD_data_ready(uartRxDataReady), 
																					 .RxD_data(uartRxDataReg));
						
		
reg [8:0] ufmAddr;
reg [3:0] arrLen;
reg [3:0] arrInd;

reg [3:0] readArrInd;
reg [3:0] readArrLen;

reg dataValidR;  always @(posedge CLK_10MHZ) dataValidR <= ufmDataValid;
wire ufmDataValidPE = ufmDataValid && ~dataValidR;
wire ufmDataValidNE = ~ufmDataValid && dataValidR;
//wire ufmDataValid;
wire [15:0] dataout;


reg [15:0] ufmnReadR; 
//reg ufmnRead = 1'b1; 


altufm ufm(.addr(ufmAddr), 
			  .nread(ufmnRead), 
			  .data_valid(ufmDataValid), 
			  .dataout(dataout));	
			  
//reg [3:0] commonStartArr [0:2];
//reg [7:0] pollReqArr [0:2];
//reg [7:0] resetReqArr [0:2];
//reg [7:0] ackArr[0:2];
//reg [7:0] writeBillTypeArr[0:4];
																					 
//reg [23:0] clockDivider = 0;

reg uartStart=0;
reg [7:0] uartDataReg;

wire [7:0] uartRxDataReg;
wire uartRxDataReady;
reg uartRxDataReadyR; always @(posedge CLK_10MHZ) uartRxDataReadyR <= uartRxDataReady;
wire uartRxDataReadyPE = ((uartRxDataReady==1'b1)&&(uartRxDataReadyR==1'b0));

wire uartTxBusy;
reg uartTxBusyR; always @(posedge CLK_10MHZ) uartTxBusyR <= uartTxBusy;
wire uartTxBusyPE = uartTxBusy && ~uartTxBusyR;
wire uartTxBusyNE = ~uartTxBusy && uartTxBusyR;
wire uartTxFree = ~uartTxBusy && ~uartTxBusyR;

parameter idleExchState =  				  0;
parameter readExchState0 = 				  1;
parameter readExchState1 = 				  2;
parameter readDataExchState = 			  3;
parameter readBillDataExchState = 		  4;
parameter readPackedBillValueExchState = 5;

parameter sendArrExchState =  1;
parameter delayExchState = 	2;



parameter powerUpBVState =   5'h10;	//8'h10: bvState <= powerUpState
parameter unknownBVState =   1;
parameter needAckBVState =   2;	
parameter initBVState = 	  8'h13;	//8'h13: bvState <= initState
parameter idleBVState = 	  8'h14;	//8'h14: bvState <= idleState										
parameter acceptingBVState = 8'h15; //8'h15: bvState <= acceptingState
parameter stackingBVState =  8'h17; //8'h17: bvState <= stackingState
parameter rejectingBVState = 8'h18;	//8'h18
parameter disableBVState =   8'h19;	//8'h19: bvState <= disableState
parameter stackedBVState =   8'h81; //8'h17: bvState <= stackingState
			
						
parameter pollReqArrAddr = 8'h00;
parameter pollReqArrLen = 4'd6;

parameter resetArrAddr = 8'h08;
parameter resetArrLen = 4'd6;

parameter ackArrAddr = 8'h10;
parameter ackArrLen = 4'd6;

parameter writeBillTypeArrAddr = 8'h18;
parameter writeBillTypeArrLen = 8'd12;

reg [1:0] bvExchWriteState = idleExchState;
reg [2:0] bvExchReadState = idleExchState;
reg [7:0] bvState = unknownBVState;




//initial begin
//	commonStartArr[0] = 4'h2;
//	commonStartArr[1] = 4'h3;
//	commonStartArr[2] = 4'h6;
//	
//	resetReqArr[0] = 8'h30;  //commStart
//	resetReqArr[1] = 8'h41;
//	resetReqArr[2] = 8'hb3;
//
//	pollReqArr[0] = 8'h33; //commStart
//	pollReqArr[1] = 8'hda;
//	pollReqArr[2] = 8'h81;
//		
//	ackArr[0] = 8'h00; //commStart
//	ackArr[1] = 8'hc2;
//	ackArr[2] = 8'h82;
//	
//	writeBillTypeArr[0] = 8'h0C;  //2
//	writeBillTypeArr[1] = 8'h34;
//	writeBillTypeArr[2] = 8'hB5; //5
//	writeBillTypeArr[3] = 8'hC1;
//end

always @(posedge CLK_10MHZ) begin
	
	case(bvExchReadState)
		idleExchState: begin
			if(uartRxDataReadyPE) begin
				if(uartRxDataReg == 8'h02) begin
					bvExchReadState <= readExchState0;
				end
			end
		end

	//----- readState0 ------
		readExchState0: 
			if(uartRxDataReadyPE) begin
				if(uartRxDataReg == 8'h03)
					bvExchReadState <= readExchState1;								
				else 				
					bvExchReadState <= idleBVState;						
			end
		readExchState1: 
			if(uartRxDataReadyPE) begin				
				
				readArrLen <= uartRxDataReg-3;
				readArrInd <= 0;				
				if(uartRxDataReg == 8'h06)
					bvExchReadState <= readDataExchState;											
				else if(uartRxDataReg == 8'h07)
					bvExchReadState <= readBillDataExchState;
				
			end

		readDataExchState: begin
			if(uartRxDataReadyPE) begin	
				readArrInd <= readArrInd + 1'b1;
				if(readArrInd == 8'h00) begin
					bvState[7:0] <= uartRxDataReg[7:0];

					//case(uartRxDataReg)
//						8'h10: bvState <= powerUpState;
//						8'h13: bvState <= initState;
//						8'h14: bvState <= idleState;											
//						8'h15: bvState <= acceptingState;
//						8'h17: bvState <= stackingState;						
//						8'h19: bvState <= disableState;						
					//rejectingBVState: bvState <= needAckBVState;
					//stackingBVState:	bvState <= needAckBVState;
					//stackedBVState:	bvState <= needAckBVState;						
					//endcase				
				end						
			end
			if(readArrInd == readArrLen) begin
				//bvState <= needAckBVState;	//sendAckState
				bvExchReadState <= idleExchState;
			end
		end

		//----- readBillDataState ------
		readBillDataExchState: begin
			if(uartRxDataReadyPE) begin	
				arrInd <= arrInd + 1'b1;	
				case(uartRxDataReg)
					8'h81: bvExchReadState <= readPackedBillValueExchState;
					8'h1c: begin //rejectingState
						bvExchReadState <= idleExchState;		
						bvState <= rejectingBVState;			
						//bvExchState <= sendArrState;		//sendAckState								
					end
				endcase										
			end
			if(arrInd == arrLen) begin
				bvState <= needAckBVState; //sendAck
				bvExchReadState <= idleExchState;
			end
		end
		
		//----- readPackedBillValue ------
		readPackedBillValueExchState: begin
			if(uartRxDataReadyPE) begin
				bvExchReadState <= idleExchState;
				case(uartRxDataReg)
					8'h02: billAccumed <= billAccumed + 8'd10;
					8'h03: billAccumed <= billAccumed + 8'd50;
					8'h04: billAccumed <= billAccumed + 8'd100;		
					default: ;
				endcase				
				bvState <= needAckBVState;
			end		
		end		
	endcase
	
	//----- ---- ------
	//----- ---- ------
	
	case(bvExchWriteState)
	//----- idle ------
		idleExchState: begin
			begin
				arrInd <= 4'h1;
				ufmnRead <= 1'b0;	
				bvExchWriteState <= sendArrExchState;  
				case(bvState) 
					powerUpBVState: begin
						ufmAddr <= resetArrAddr;
						arrLen <=  resetArrLen;				//sendReset												
					end
					
					disableBVState: begin
						ufmAddr <= writeBillTypeArrAddr;
						arrLen <=  writeBillTypeArrLen;		 //sendBill														
					end			
									
					//rejectingBVState:
					//stackingBVState:	
					//stackedBVState:
					needAckBVState:					
					begin
						ufmAddr <= ackArrAddr;
						arrLen <=  ackArrLen;				//sendAck						
					end
					
					default: begin 				
						ufmAddr <= pollReqArrAddr;
						arrLen <=  pollReqArrLen;			//sendPoll						
					end
				endcase
				
			end
		end
		
		
		//----- sendArrState ------
		sendArrExchState: begin 				
			if(uartTxFree && ufmDataValid && uartStartSignal) begin			
				uartStart <= 1'b1;				
				uartDataReg[7:0] <= dataout[15:8];													
				
				ufmAddr <= ufmAddr + 8'd1;
				ufmnRead <= 1'b0;				
				arrInd <= arrInd + 4'd1;				
				if(arrInd[3:0] == arrLen[3:0]) begin
					bvExchWriteState <= delayExchState;	
					arrInd[3:0] <= 4'hf;
					arrLen[3:0] <= 4'hf;
					bvState <= unknownBVState;
				end				
			end
		end	
		
		//----- delay state ------
		delayExchState: begin
			if(uartStartSignal) begin
				arrInd[3:0] <= arrInd[3:0] - 1;
			end			
			if(arrInd[3:0] == 4'h0) begin
				arrLen[3:0] <= arrLen[3:0] - 1;
				arrInd[3:0]	<= 4'hf;		
				//bvExchWriteState <= idleExchState;	
			end
			if(arrLen[3:0] == 4'h0) begin
				bvExchWriteState <= idleExchState;					
			end			
		end
	endcase

	if(ufmDataValidNE)
		ufmnRead <= 1'b1;	
	if(uartTxBusyPE)
		uartStart <= 1'b0;	
		
	
end

																					 
  
endmodule


