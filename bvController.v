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
						
reg ufmnRead = 1'b1;
reg [8:0] ufmAddr;
reg [3:0] arrLen;
reg [3:0] arrInd;
reg dataValidR;  always @(posedge CLK_10MHZ) dataValidR <= data_valid;
wire data_valid;
wire [7:0] dataout;
wire dataValidWire = data_valid && !dataValidR;

altufm ufm(.addr(ufmAddr), .nread(ufmnRead), .data_valid(data_valid), .dataout(dataout))	;																				 

//reg [3:0] commonStartArr [0:2];
//reg [7:0] pollReqArr [0:2];
//reg [7:0] resetReqArr [0:2];
//reg [7:0] ackArr[0:2];
//reg [7:0] writeBillTypeArr[0:4];
																					 
//reg [23:0] clockDivider = 0;

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
parameter pollReqArrLen = 8'd6;

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

	//if(uartDataStartMsg) begin
		//billAccumed <= uartRxDataReg;
	//end
	
	case(bvExchState)
	//----- idle ------
		idleExchState: begin
			if(uartTxFree) begin
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
//					rejectingState: begin
//						ufmAddr <= ackArrAddr;
//						arrLen <=  ackArrLen;
//						ufmnRead <= 1'b0;
//						arrInd <= 4'h0;
//						bvExchState <= sendArrState; //sendBill
//					end
					default: begin 				
						ufmAddr <= pollReqArrAddr;
						arrLen <=  pollReqArrLen;
						ufmnRead <= 1'b0;
						arrInd <= 4'h0;
						bvExchState <= sendArrState;   //sendPoll
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
				
				arrLen <= uartRxDataReg;
				arrInd <= 0;				
				if(uartRxDataReg == 8'h03)
					bvExchState <= readDataState;											
				else if(uartRxDataReg == 8'h04)
					bvExchState <= readBillDataState;
				
			end

		readDataState: begin
			if(uartDataStartMsg) begin	
				arrInd <= arrInd + 1'b1;
				if(arrInd == 8'h00) begin
					//bvState <= uartRxDataReg;
					case(uartRxDataReg)
						8'h10: bvState <= powerUpState;
						8'h13: bvState <= initState;
						8'h19: bvState <= disableState;
						//8'h14: bvState <= idleState;
						//8'h15: bvState <= acceptingState;
						//8'h17: bvState <= stackingState;						
					endcase				
				end						
			end
			if(arrInd == arrLen) begin
				bvExchState <= sendArrState;	//sendAckState
			end
		end

		//----- readBillDataState ------
		readBillDataState: begin
			if(uartDataStartMsg) begin	
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
			if(uartDataStartMsg) begin
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
			if( uartTxFree && dataValidWire ) begin								
				uartDataReg <= dataout;				
				uartStart <= 1'b1;				
			end			
			if(uartBusyStart) begin
				uartStart <= 1'b0;
				arrInd <= arrInd + 4'd1;				
			end
			if(uartBusyEnd) begin
				if(arrInd == arrLen) begin
					bvExchState <= idleExchState;				
				end		
				else begin					
					uartDataReg <= dataout;
					uartStart	<= 1'b1;			
				end
			end
		end
			

		

		
		default: ;	
	endcase

	
end

																					 
  
endmodule


