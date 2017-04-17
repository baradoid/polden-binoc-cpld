module bv_controller (
    input CLK_10MHZ,	
	 input uartRxPin,
	 output uartTxPin,
    output reg[ 7:0] billAccumed = 8'h0
  );
  
  

async_transmitter #(.ClkFrequency(10000000), .Baud(19200)) TXBV(.clk(CLK_10MHZ), 
																					 .TxD(uartTxPin), 
																					 .TxD_start(start), 
																					 .TxD_data(uartDataReg),
																					 .TxD_busy(txBusy));
																					 
async_receiver #(.ClkFrequency(10000000), .Baud(19200)) RXBV(.clk(CLK_10MHZ), 
																					 .RxD(uartRxPin), 
																					 .RxD_data_ready(uartDataReady), 
																					 .RxD_data(uartRxDataReg));

reg [3:0] commonStartArr [0:2];
reg [7:0] pollReqArr [0:2];
reg [7:0] resetReqArr [0:2];
reg [7:0] ackArr[0:2];
reg [7:0] writeBillTypeArr[0:11];
																					 
reg [23:0] clockDivider = 0;
reg start;
reg [7:0] uartDataReg;

wire [7:0] uartRxDataReg;
wire uartDataReady;
reg [1:0] uartDataReadyR; always @(posedge CLK_10MHZ) uartDataReadyR <= {uartDataReadyR[0], uartDataReady};
wire uartDataStartMsg = (uartDataReadyR[1:0]==2'b01);

wire txBusy;
reg [1:0] txBusyR; always @(posedge CLK_10MHZ) txBusyR <= {txBusyR[0], txBusy};
wire uartBusyEnd = (txBusyR[1:0]==2'b10);
wire uartTxFree = (txBusyR[1:0]==2'b00);

parameter idleExchState = 0;
parameter readState0 = idleExchState+1;
parameter readState1 = readState0+1;
parameter readDataState = readState1+1;
parameter sendState = readDataState+1;
parameter sendAckState = sendState+1; 
parameter readBillDataState = sendAckState+1;
parameter sendBillTypeArrState = readBillDataState+1;
parameter sendResetArrState = sendBillTypeArrState+1;


parameter unknownState = 0;
parameter powerUpState = unknownState+1;
parameter idleState = powerUpState+1;
parameter initState = idleState+1;
parameter disableState = initState+1;
parameter acceptingState = disableState+1;
parameter stackingState = acceptingState+1;
parameter rejectingState = stackingState+1;

reg [3:0] bvExchState = idleExchState;
reg [3:0] bvState = unknownState;

reg [3:0] bTrCnt = 0;
reg [3:0] bTrInd = 0;

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
	
	writeBillTypeArr[0] = 8'h02;
	writeBillTypeArr[1] = 8'h03;
	writeBillTypeArr[2] = 8'h0C;
	writeBillTypeArr[3] = 8'h34;
	writeBillTypeArr[4] = 8'hFF;
	writeBillTypeArr[5] = 8'hFF;
	writeBillTypeArr[6] = 8'hFF;
	writeBillTypeArr[7] = 8'h00;
	writeBillTypeArr[8] = 8'h00;
	writeBillTypeArr[9] = 8'h00;
	writeBillTypeArr[10] = 8'hB5;
	writeBillTypeArr[11] = 8'hC1;
end

always @(posedge CLK_10MHZ) begin
	if(clockDivider == 10000000) begin
		clockDivider = 0;		
		//start <= 1'b1;		
	end
	else begin
		clockDivider = clockDivider + 24'd1;			
		start <= 1'b0;
	end
	
	//if(uartDataStartMsg) begin
		billAccumed <= uartRxDataReg;
	//end
	
	case(bvExchState)
	//----- idle ------
		idleExchState: begin	
			case(bvState) 
				powerUpState: begin
					bTrInd <= 0;
					bTrCnt <= 6;
					bvExchState <= sendResetArrState;
				end
				disableState: begin
					bTrInd <= 0;
					bTrCnt <= 12;
					bvExchState <= sendBillTypeArrState;
					bvState	<= unknownState;
				end			
				default: begin 				
				end
			endcase
			if(uartDataStartMsg) begin
				if(uartRxDataReg == 8'h02) begin
					bvExchState <= readState0;													
				end
			end
			else if(uartTxFree) begin
				bTrInd <= 0;
				bTrCnt <= 6;
				bvExchState <= sendState;
			end
		end
		
	//----- readState0 ------
		readState0: 
			if(uartDataStartMsg) begin
				if(uartRxDataReg == 8'h02)
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
				bvExchState <= sendAckState;
				bTrInd <= 0;
				bTrCnt <= 6;			
			end
		end

		readBillDataState: begin
			if(uartDataStartMsg) begin	
				bTrInd <= bTrInd + 1'b1;								
				if(bTrInd == 8'h81) begin //rubles packed
					billAccumed <= uartRxDataReg;					
				end						
				else if(bTrInd == 8'h1c) begin
					bvState <= rejectingState;
					bvExchState <= sendAckState;   
					bTrInd <= 0;
					bTrCnt <= 6;					
				end
			end
			if(bTrInd == bTrCnt) begin
				bvExchState <= sendAckState;
				bTrInd <= 0;
				bTrCnt <= 6;			
			end
		end
		
		sendState: begin
			if(uartTxFree) begin
				start	<= 1'b1;
				uartDataReg <= pollReqArr[bTrInd];
				bTrInd = bTrInd + 4'd1;				
			end
			else begin
				start	<= 1'b0;
			end
			if(bTrInd == bTrCnt) begin
				bvExchState <= idleExchState;				
			end
		end
		
		
		sendAckState: begin
				if(uartTxFree) begin
					start	<= 1'b1;
					uartDataReg <= ackArr[bTrInd];
					bTrInd = bTrInd + 4'd1;				
				end
				else begin
					start	<= 1'b0;
				end
				if(bTrInd == bTrCnt) begin
					bvExchState <= idleExchState;					
				end
			end
			
		sendBillTypeArrState: begin
			if(uartTxFree) begin
				start	<= 1'b1;
				uartDataReg <= writeBillTypeArr[bTrInd];
				bTrInd = bTrInd + 4'd1;				
			end
			else begin
				start	<= 1'b0;
			end
			if(bTrInd == bTrCnt) begin
				bvExchState <= idleExchState;					
			end		
		end
		
		sendResetArrState: begin
			if(uartTxFree) begin
				start	<= 1'b1;
				uartDataReg <= resetReqArr[bTrInd];
				bTrInd = bTrInd + 4'd1;				
			end
			else begin
				start	<= 1'b0;
			end
			if(bTrInd == bTrCnt) begin
				bvExchState <= idleExchState;				
			end
		end
		
		default: ;	
	endcase

	
end

																					 
  
endmodule


