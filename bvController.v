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
wire uartRxDataStartMsg = ((uartRxDataReady==1'b1)&&(uartRxDataReadyR==1'b0));

wire uartTxBusy;
reg uartTxBusyR; always @(posedge CLK_10MHZ) uartTxBusyR <= uartTxBusy;
wire uartTxBusyPE = uartTxBusy && ~uartTxBusyR;
wire uartTxBusyNE = ~uartTxBusy && uartTxBusyR;
wire uartTxFree = ~uartTxBusy && ~uartTxBusyR;

parameter idleExchState = 0;
parameter readState0 = idleExchState+1;
parameter readState1 = readState0+1;
parameter readDataState = readState1+1;
parameter readBillDataState = readDataState+1;
parameter readPackedBillValue = readBillDataState+1;
parameter sendArrState = readPackedBillValue+1;



parameter unknownState = 0;
parameter powerUpState = unknownState+1;
parameter idleState = powerUpState+1;
parameter initState = idleState+1;
parameter disableState = initState+1;
parameter acceptingState = disableState+1;
parameter stackingState = acceptingState+1;
parameter rejectingState = stackingState+1;

parameter pollReqArrAddr = 8'h00;
parameter pollReqArrLen = 4'd6;

parameter resetArrAddr = 8'h08;
parameter resetArrLen = 8'd6;

parameter ackArrAddr = 8'h10;
parameter ackArrLen = 8'd6;

parameter writeBillTypeArrAddr = 8'h18;
parameter writeBillTypeArrLen = 8'd12;

reg [2:0] bvExchState = idleExchState;
reg [3:0] bvState = unknownState;




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
	
	case(bvExchState)
	//----- idle ------
		idleExchState: begin
			if(uartRxDataStartMsg) begin
				if(uartRxDataReg == 8'h02) begin
					bvExchState <= readState0;													
				end
			end
			else begin
				case(bvState) 
					powerUpState: begin
						ufmAddr <= resetArrAddr;
						arrLen <=  resetArrLen;
						ufmnRead <= 1'b0;
						arrInd <= 4'h0;
						bvExchState <= sendArrState;  //sendReset
					end
					disableState: begin
						ufmAddr <= writeBillTypeArrAddr;
						arrLen <=  writeBillTypeArrLen;
						ufmnRead <= 1'b0;
						arrInd <= 4'h0;
						bvExchState <= sendArrState; //sendBill
					end			
					rejectingState: begin
						ufmAddr <= ackArrAddr;
						arrLen <=  ackArrLen;
						ufmnRead <= 1'b0;
						arrInd <= 4'h0;
						bvExchState <= sendArrState; //sendBill
					end
					default: begin 				
						ufmAddr <= pollReqArrAddr;
						arrLen <=  pollReqArrLen;
						ufmnRead <= 1'b0;
						arrInd <= 4'h1;
						bvExchState <= sendArrState;   //sendPoll
					end
				endcase
			end
		end
		
	//----- readState0 ------
		readState0: 
			if(uartRxDataStartMsg) begin
				if(uartRxDataReg == 8'h03)
					bvExchState <= readState1;								
				else 				
					bvExchState <= idleState;						
			end
		readState1: 
			if(uartRxDataStartMsg) begin				
				
				arrLen <= uartRxDataReg;
				arrInd <= 0;				
				if(uartRxDataReg == 8'h03)
					bvExchState <= readDataState;											
				else if(uartRxDataReg == 8'h04)
					bvExchState <= readBillDataState;
				
			end

		readDataState: begin
			if(uartRxDataStartMsg) begin	
				arrInd <= arrInd + 1'b1;
				if(arrInd == 8'h00) begin
					//bvState <= uartRxDataReg;
					case(uartRxDataReg)
						8'h10: bvState <= powerUpState;
						8'h13: bvState <= initState;
						8'h19: bvState <= disableState;
						8'h14: bvState <= idleState;
						8'h15: bvState <= acceptingState;
						8'h17: bvState <= stackingState;						
					endcase				
				end						
			end
			if(arrInd == arrLen) begin
				bvExchState <= sendArrState;	//sendAckState
			end
		end

		//----- readBillDataState ------
		readBillDataState: begin
			if(uartRxDataStartMsg) begin	
				arrInd <= arrInd + 1'b1;	
				case(uartRxDataReg)
					8'h81: bvExchState <= readPackedBillValue;
					8'h1c: begin //rejectingState
						bvExchState <= idleExchState;		
						bvState <= rejectingState;			
						//bvExchState <= sendArrState;		//sendAckState								
					end
				endcase										
			end
			if(arrInd == arrLen) begin
				bvExchState <= sendArrState; //sendAck
			end
		end
		
		//----- readPackedBillValue ------
		readPackedBillValue: begin
			if(uartRxDataStartMsg) begin
				bvExchState <= idleExchState;
				case(uartRxDataReg)
					8'h02: billAccumed <= billAccumed + 8'd10;
					8'h03: billAccumed <= billAccumed + 8'd50;
					8'h04: billAccumed <= billAccumed + 8'd100;		
					default: ;
				endcase				
			end
		end
		
		//----- sendArrState ------
		sendArrState: begin 				
			if(uartTxFree && ufmDataValid && uartStartSignal) begin			
				uartStart <= 1'b1;				
				uartDataReg[7:0] <= dataout[15:8];													
				
				ufmAddr <= ufmAddr + 8'd1;
				ufmnRead <= 1'b0;				
				arrInd <= arrInd + 4'd1;				
				if(arrInd[3:0] == arrLen[3:0]) begin
					bvExchState <= idleExchState;	
				end				
			end
		end		
	endcase

	if(ufmDataValidNE)
		ufmnRead <= 1'b1;	
	if(uartTxBusyPE)
		uartStart <= 1'b0;	
		
	
end

																					 
  
endmodule


