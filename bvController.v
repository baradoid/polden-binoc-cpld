module bv_controller (
    input CLK_10MHZ,	
	 input uartRxPin,
	 output uartTxPin,
    output reg[ 7:0] billAccumed = 8'h0
  );
  
  

async_transmitter #(.ClkFrequency(10000000), .Baud(19200)) TXBV(.clk(CLK_10MHZ), 
																					 .TxD(uartTxPin), 
																					 .TxD_start(uartStart), 
																					 .TxD_data(uartDataReg),
																					 .TxD_busy(txBusy));
																					 
async_receiver #(.ClkFrequency(10000000), .Baud(19200)) RXBV(.clk(CLK_10MHZ), 
																					 .RxD(uartRxPin), 
																					 .RxD_data_ready(uartDataReady), 
																					 .RxD_data(uartRxDataReg));
																					 
reg [8:0] addr;																					 
wire data_valid;
wire [7:0] dataout;
altufm (.addr(addr), .data_valid(data_valid), .dataout(dataout))	;																				 

reg [3:0] commonStartArr [0:2];
reg [7:0] pollReqArr [0:2];
reg [7:0] resetReqArr [0:2];
reg [7:0] ackArr[0:2];
reg [7:0] writeBillTypeArr[0:4];
																					 
//reg [23:0] clockDivider = 0;
reg start;
reg uartStart=0;
reg [7:0] uartDataReg;

wire [7:0] uartRxDataReg;
wire uartDataReady;
reg [1:0] uartDataReadyR; always @(posedge CLK_10MHZ) uartDataReadyR <= {uartDataReadyR[0], uartDataReady};
wire uartDataStartMsg = (uartDataReadyR[1:0]==2'b01);

wire txBusy;
reg [1:0] txBusyR; always @(posedge CLK_10MHZ) txBusyR <= {txBusyR[0], txBusy};
wire uartBusyStart = (txBusyR[1:0]==2'b01);
wire uartBusyEnd = (txBusyR[1:0]==2'b10);
wire uartTxFree = (txBusyR[1:0]==2'b00);

parameter idleExchState = 0;
parameter readState0 = idleExchState+1;
parameter readState1 = readState0+1;
parameter readDataState = readState1+1;
parameter readBillDataState = readDataState+1;
parameter sendCommonArrState = readBillDataState+1;
parameter sendPollState = sendCommonArrState+1;
parameter sendAckState = sendPollState+1; 
parameter sendResetArrState = sendAckState+1;

parameter readPackedBillValue = sendResetArrState+1;

parameter sendBillTypeArrState0 = readPackedBillValue+1;
parameter sendBillTypeArrState1 = readPackedBillValue+2;
parameter sendBillTypeArrState2 = readPackedBillValue+3;
parameter sendBillTypeArrState3 = readPackedBillValue+4;
parameter sendBillTypeArrState4 = readPackedBillValue+5;


//reg [2:0] billArrState = 0;

//parameter arrTypePoll=0;
//parameter arrTypeAck=1;
//parameter arrTypeReset=2;
//reg [1:0] arrType;

parameter unknownState = 0;
parameter powerUpState = unknownState+1;
parameter idleState = powerUpState+1;
parameter initState = idleState+1;
parameter disableState = initState+1;
parameter acceptingState = disableState+1;
parameter stackingState = acceptingState+1;
parameter rejectingState = stackingState+1;

reg [3:0] bvExchState = idleExchState;
reg [3:0] bvExchAfterSendCommonState = idleExchState;
reg [3:0] bvState = unknownState;
reg [3:0] bTrCnt, bTrInd;

initial begin
	commonStartArr[0] = 4'h2;
	commonStartArr[1] = 4'h3;
	commonStartArr[2] = 4'h6;
	
	resetReqArr[0] = 8'h30;  //commStart
	resetReqArr[1] = 8'h41;
	resetReqArr[2] = 8'hb3;

	pollReqArr[0] = 8'h33; //commStart
	pollReqArr[1] = 8'hda;
	pollReqArr[2] = 8'h81;
		
	ackArr[0] = 8'h00; //commStart
	ackArr[1] = 8'hc2;
	ackArr[2] = 8'h82;
	
	writeBillTypeArr[0] = 8'h0C;  //2
	writeBillTypeArr[1] = 8'h34;
	writeBillTypeArr[2] = 8'hB5; //5
	writeBillTypeArr[3] = 8'hC1;
end

always @(posedge CLK_10MHZ) begin
//	if(clockDivider == 10000000) begin
//		clockDivider = 0;		
//		//start <= 1'b1;		
//	end
//	else begin
//		clockDivider = clockDivider + 24'd1;			
//		start <= 1'b0;
//	end
	
	//if(uartDataStartMsg) begin
		//billAccumed <= uartRxDataReg;
	//end
	
	case(bvExchState)
	//----- idle ------
		idleExchState: begin
			if(uartTxFree) begin
				case(bvState) 
					powerUpState: begin
						bvExchState <= sendCommonArrState;
						bvExchAfterSendCommonState <= sendResetArrState;
					end
					disableState: begin
						//billArrState <= 0;
						bvExchState <= sendBillTypeArrState0;
						bvState	<= unknownState;
					end			
					default: begin 				
						bvExchState <= sendCommonArrState;
						bvExchAfterSendCommonState <= sendPollState;
					end
				endcase
			end
			else if(uartDataStartMsg) begin
				if(uartRxDataReg == 8'h02) begin
					bvExchState <= readState0;													
				end
			end
		end
		
	//----- readState0 ------
		readState0: 
			if(uartDataStartMsg) begin
				if(uartRxDataReg == 8'h03)
					bvExchState <= readState1;								
				else 				
					bvExchState <= idleState;						
			end
		readState1: 
			if(uartDataStartMsg) begin				
				
				bTrCnt <= uartRxDataReg;
				bTrInd <= 0;				
				if(uartRxDataReg == 8'h03)
					bvExchState <= readDataState;											
				else if(uartRxDataReg == 8'h04)
					bvExchState <= readBillDataState;
				
			end

		readDataState: begin
			if(uartDataStartMsg) begin	
				bTrInd <= bTrInd + 1'b1;
				if(bTrInd == 8'h00) begin
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
			if(bTrInd == bTrCnt) begin
				bvExchState <= sendCommonArrState;
				bvExchAfterSendCommonState <= sendAckState;			
			end
		end

		//----- readBillDataState ------
		readBillDataState: begin
			if(uartDataStartMsg) begin	
				bTrInd <= bTrInd + 1'b1;	
				case(uartRxDataReg)
					8'h81: bvExchState <= readPackedBillValue;
					8'h1c: begin //rejectingState
						bvExchState <= sendCommonArrState;
						bvExchAfterSendCommonState <= sendAckState;											
					end
				endcase										
			end
			if(bTrInd == bTrCnt) begin
				bvExchState <= sendCommonArrState;
				bvExchAfterSendCommonState <= sendAckState;	
			end
		end
		
		//----- readPackedBillValue ------
		readPackedBillValue: begin
			if(uartDataStartMsg) begin
				bvExchState <= idleExchState;
				case(uartRxDataReg)
					8'h02: billAccumed <= billAccumed + 8'd10;
					8'h03: billAccumed <= billAccumed + 8'd50;
					8'h04: billAccumed <= billAccumed + 8'd100;				
				endcase				
			end
		end
		
		//----- sendBillTypeArrState ------
		sendBillTypeArrState0: begin
			if(uartTxFree) begin				
				uartDataReg <= {4'h0, commonStartArr[0]};
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 2'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= sendBillTypeArrState1;				
				end		
				else begin
					//uartDataReg <= commonStartArr[bTrInd];
					uartDataReg <= dataout;
					uartStart	<= 1'b1;			
				end
			end
		end
		
		sendBillTypeArrState1: begin
			if(uartTxFree) begin				
				uartDataReg <= writeBillTypeArr[0];
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 2'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= sendBillTypeArrState2;				
				end		
				else begin
					uartDataReg <= writeBillTypeArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end
		
		sendBillTypeArrState2: begin
			if(uartTxFree) begin				
				uartDataReg <= 8'hFF;
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd4;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= sendBillTypeArrState3;				
				end		
				else begin
					//uartDataReg <= 8'hFF;
					uartStart	<= 1'b1;			
				end
			end
		end
		
		sendBillTypeArrState3: begin
			if(uartTxFree) begin				
				uartDataReg <= 8'h00;
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= sendBillTypeArrState4;				
				end		
				else begin
					//uartDataReg <= 8'h00;
					uartStart	<= 1'b1;			
				end
			end
		end
		
		sendBillTypeArrState4: begin
			if(uartTxFree) begin				
				uartDataReg <= writeBillTypeArr[2];
				bTrInd <= 4'h2;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd4;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= idleExchState;				
				end		
				else begin
					uartDataReg <= writeBillTypeArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end


		
		//----- sendCommonArrState ------
		sendCommonArrState: begin
			if(uartTxFree) begin				
				uartDataReg <= {4'h0, commonStartArr[0]};
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= bvExchAfterSendCommonState;				
				end		
				else begin
					uartDataReg <= commonStartArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end
		
		//----- sendResetLastArrState ------
		sendResetArrState: begin
			if(uartTxFree) begin				
				uartDataReg <= resetReqArr[0];
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= idleExchState;				
				end		
				else begin
					uartDataReg <= resetReqArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end
		
		//----- sendResetLastArrState ------
		sendAckState: begin
			if(uartTxFree) begin				
				uartDataReg <= ackArr[0];
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= idleExchState;				
				end		
				else begin
					uartDataReg <= ackArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end	

		//----- sendPollState ------
		sendPollState: begin
			if(uartTxFree) begin				
				uartDataReg <= pollReqArr[0];
				bTrInd <= 4'h0;	
				uartStart <= 1'b1;
				bTrCnt <= 4'd3;
			end			
			if(uartBusyStart) begin
				uartStart	<= 1'b0;
				bTrInd <= bTrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(bTrInd == bTrCnt) begin
					bvExchState <= idleExchState;				
				end		
				else begin
					uartDataReg <= pollReqArr[bTrInd];
					uartStart	<= 1'b1;			
				end
			end
		end	
		
		
		default: ;	
	endcase

	
end

																					 
  
endmodule


