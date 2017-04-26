
module maxv_5m570z_start_golden_top(
 
input   CLK_SE_AR,

output SYNCHRO,

// GPIO
input USER_PB0, USER_PB1,
input CAP_PB_1,
output reg USER_LED0, USER_LED1,

// Connector A 
output   [  30: 1] 	AGPIO,

// Connector B
inout    BGPIO_ONEWIRE,
//input    BGPIO_SPI_MISO,
//input    BGPIO_SPI_CLK,
input 	BGPIO_UART_RX,
output 	BGPIO_UART_TX,
input 	BV_UART_RX,  //BILL_VALIDATOR
output 	BV_UART_TX,	 //BILL_VALIDATOR

output 	ENC1_SCK,
input 	ENC1_MISO,

output 	ENC2_SCK,
input 	ENC2_MISO,

output 	ADC_SCK,
input 	ADC_MISO,

//output   [ 20: 7] 	BGPIO,
input 	BGPIO_P_1, BGPIO_N_1,
input 	BGPIO_P_2, BGPIO_N_2,
input 	BGPIO_P_3, BGPIO_N_3,

// Motor 1
input MOTOR_1_FB_A, MOTOR_1_FB_B, MOTOR_1_CTRL,
input   [  5: 0] 	MAX_MOTOR_1, 

// Motor 2
input MOTOR_2_FB_A, MOTOR_2_FB_B, MOTOR_2_CTRL,
input   [  5: 0] 	MAX_MOTOR_2, 

// Speaker
input   [  7: 0] 	MAX_SPK, 

// I2C EEPROM
input I2C_PROM_SCL, I2C_PROM_SDA, 
 
// SPI EEPROM
input SPI_MOSI, SPI_SCK, SPI_CSN, SPI_MISO 
 );  
 
// reg [7:0] outByte;
 
 //assign USER_LED0 = outByte[0];
// assign USER_LED1 = outByte[1];
 

//spi(	
//	.clk(CLK_SE_AR),
//	.rst(1'b0),
//	.miso(AGPIO[3]),
//	//.mosi(AGPIO[4]),
//	.sck(BGPIO[35]),
//	.start(start),
//	.data_in(data),
//	.data_out(spiDataWire),
//	.new_data(newDataWire)	
//);
//wire uartTick1;
//BaudTickGen #(.ClkFrequency(10000000), .Baud(230400)) tickgen(.clk(CLK_SE_AR), .enable(uartBusy), .tick(uartTick1));

wire tempDataChanged = (oneWireTemperatureL[7:0] != oneWireTemperature[7:0]);
wire billDataChanged = (billAcc[7:0] != billAccWire[7:0]);
wire enc1PosChanged = (enc1Pos[11:0] != enc1PosLast[11:0]);
wire enc2PosChanged = (enc2Pos[11:0] != enc2PosLast[11:0]);
wire adcDataChanged = (adcData[7:0] != adcDataL[7:0]);

reg [31:0] timerCounter; always @(posedge CLK_SE_AR) timerCounter <= timerCounter + 31'h1;
wire dataSendAllow = ((timerCounter[9:0] == 10'h3ff) && (tempDataChanged || billDataChanged || enc1PosChanged || enc2PosChanged || adcDataChanged));

wire encAdcSpiExchStart =  (timerCounter[10:0] == 10'hfff); //каждые 400 мкс

//assign BGPIO[30] = timerCounter[31];

//assign BGPIO[24] = BV_UART_RX;
//assign BGPIO[23] = BV_UART_TX;


wire uartBusy;
//reg [15:0] uartBusyR; always @(posedge CLK_SE_AR) uartBusyR[7:0] <= {uartBusyR[14:0], uartBusy};
reg uartEna = 0;
reg uartStartSignal = 0;
wire uartStartSignalWire = uartStartSignal && uartEna;

//reg last12BitState; always @(posedge CLK_SE_AR) last12BitState <= timerCounter[12];
//wire uart19200StartSignal = ((timerCounter[12]==0) && (last12BitState==1));
wire uart19200StartSignal = (timerCounter[12:0] == 13'h1FFF);

assign SYNCHRO = uart19200StartSignal;

//wire uartPrepDataSignal = ((uartBusy==0)&&(uartBusyR==1));
//wire uartTxFree = (uartBusyR==8'h0);
reg [7:0] uartDataReg;

//assign BGPIO[22] = uart19200StartSignal;

async_transmitter #(.ClkFrequency(10000000), .Baud(230400)) TX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.TxD(BGPIO_UART_TX), 
																					.TxD_start(uartStartSignalWire), 
																					.TxD_data(uartDataReg),
																					.TxD_busy(uartBusy));

wire uartRxDataReady;
wire [7:0] uartRxData;
//reg uartRxDataL; always @(posedge CLK_SE_AR) uartRxDataL <= uartRxDataReady;
async_receiver #(.ClkFrequency(10000000), .Baud(230400)) RX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.RxD(BGPIO_UART_RX), 
																					.RxD_data_ready(uartRxDataReady), 
																					.RxD_data(uartRxData));
																					
wire dallasPresense;		
wire clock_6mks = (timerCounter[5:2] == 4'hf);
reg last23BitState; always @(posedge CLK_SE_AR) last23BitState <= timerCounter[22];
wire dallasStart = ((timerCounter[22]==1'b0) && (last23BitState==1'b1));
wire [7:0] oneWireTemperature;
reg [7:0] oneWireTemperatureL; 
wire synchroWire;

dallas18b20Ctrl dallas18b20Ctrl_inst(.CLK_10MHZ(CLK_SE_AR),
					  .CLK_6MKS(clock_6mks),
					 .start(dallasStart),
					 .oneWirePin(BGPIO_ONEWIRE),
					 //.oneWirePinOut(BGPIO_ONEWIRE),
					 .temperature(oneWireTemperature),
					 .presenseOut(dallasPresense),
					 .startExch(synchroWire));

wire [7:0] billAccWire;
reg [7:0] billAcc;
bv_controller bv_contr_inst(.CLK_10MHZ(CLK_SE_AR),
									 .uartRxPin(BV_UART_RX),
									 .uartTxPin(BV_UART_TX),
									 .uartStartSignal(uart19200StartSignal),
									 .billAccumed(billAccWire),
									 /*.ufmDataValid(BGPIO[12]),
									 .ufmnRead(BGPIO[10])*/);
										


//reg adcStart;
reg spi1BusyR, spi2BusyR, spiAdcBusyR; 
wire spi1Busy, spi2Busy,  spiAdcBusy;

always @(posedge CLK_SE_AR) begin
	spi1BusyR <= spi1Busy;
	spi2BusyR <= spi2Busy;
	spiAdcBusyR <= spiAdcBusy;
	
	USER_LED0 <= ~dallasPresense;
	USER_LED1 <= ~tempDataChanged;
	
	//SYNCHRO <= synchroWire;
	//SYNCHRO <= dallasStart;

end

wire [7:0] adcData;
reg [7:0] adcDataL;
wire spiNewData;

wire [11:0] enc1Pos, enc2Pos;				 
wire enc1NewData, enc2NewData;
reg  [11:0]	enc1PosLast, enc2PosLast;		


spi #(.CLK_DIV(8)) spi_enc1Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(ENC1_SCK),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(encAdcSpiExchStart),
				 .miso(ENC1_MISO),				 
				 //.data_in(spiDataIn),
				 .data_out(enc1Pos),
				 .new_data(enc1NewData));

spi #(.CLK_DIV(8)) spi_enc2Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(ENC2_SCK),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(encAdcSpiExchStart),
				 .miso(ENC2_MISO),				 
				 //.data_in(spiDataIn),
				 .data_out(enc2Pos),
				 .new_data(enc2NewData));

spi #(.CLK_DIV(8)) spi_AdcInst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(ADC_SCK),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(encAdcSpiExchStart),
				 .miso(ADC_MISO),				 
				 //.data_in(spiDataIn),
				 .data_out(adcData),
				 .new_data(spiNewData));
				 

		 

reg [7:0] dataIn;
wire newDataWire;
wire [7:0] spiDataWire;

reg [3:0] transDataIn;
wire [7:0] transDataOut = (transDataIn[3:0]<4'hA)? (transDataIn[3:0]+8'h30):(transDataIn[3:0]+8'h37);

//reg [4:0] uartState = 0;
wire [4:0] uartState = timerCounter[14:10];

reg regsChanged = 0;

always @(posedge CLK_SE_AR) begin
			
//	if(clockDivider == 24'd10000000) begin
//		clockDivider = 0;		
//		USER_LED0 = ~USER_LED0;
//		USER_LED1 = ~USER_LED1;
//	end
//	else begin
//		clockDivider = clockDivider + 24'd1;			
//	end
	
//	if(clockCntStart == 24'd10000) begin
//		start <= 1'b1;
//		adcStart <= 1'b1;
//		clockCntStart <= 0;	
//	end
//	else begin
//		clockCntStart <= clockCntStart + 24'd1;			
//		start <= 1'b0;
//		adcStart <= 1'b0;
//	end
	
//	if(tempMeasStartCnt == 24'd5000000) begin		
//		tempMeasStartCnt <= 0;	
//		tempMeasStart <= 1'b1;
//	end
//	else begin
//		tempMeasStartCnt <= tempMeasStartCnt + 24'd1;			
//		tempMeasStart <= 1'b0;
//	end


	if(newDataWire) begin
		dataIn <= spiDataWire;	
	end
	

	if(dataSendAllow) begin
		//SYNCHRO <= 1;	
		//uartState <= uartState + 5'd1;			
		
		uartStartSignal <= 1'b1;				
		case(uartState)			
			0: begin
				//
				transDataIn <= enc1Pos[11:8];
				end
			1: begin 				
				uartEna <= 1;
				transDataIn <= enc1Pos[7:4]; 
				uartDataReg <= transDataOut;
				//uartDataReg <= "B";					
				end 
			2: begin 
				transDataIn <= enc1Pos[3:0];
				uartDataReg <= transDataOut;
				//uartDataReg <= "C";				
				end
			3: begin
				uartDataReg <= transDataOut;
				//uartDataReg <= "D";				
				end
			4: begin
				transDataIn <= enc2Pos[11:8];
				uartDataReg <= " ";
				//uartDataReg <= "E";				
				end			
			5: begin
				transDataIn <= enc2Pos[7:4]; 
				uartDataReg <= transDataOut;
				//uartDataReg <= "F";				
				end
			6: begin
				transDataIn <= enc2Pos[3:0];				
				uartDataReg <= transDataOut;  //dallas			
				end
			7: begin 
				uartDataReg <= transDataOut;						
				end
			8: begin 
				transDataIn <= 4'hb;				
				uartDataReg <= " ";										
				end
			9:	begin 
				transDataIn <= 4'hc;				
				uartDataReg <= transDataOut;										
				end				
			10:	begin 				
				uartDataReg <= transDataOut;										
				end				
			11:begin				
				transDataIn <= oneWireTemperature[7:4];				
				uartDataReg <= " ";										
				end
			12: begin
				transDataIn <= oneWireTemperature[3:0];
				uartDataReg <= transDataOut;			
				end
			13: begin				
				uartDataReg <= transDataOut;				
				end
			14: begin
				uartDataReg <= " ";			
				transDataIn <= billAccWire[7:4];				 
				end
			15: begin
				 transDataIn <= billAccWire[3:0];				 
				 uartDataReg <= transDataOut;			
				end
			
			16: begin 				 				 				 
				 uartDataReg <= transDataOut;
				 billAcc[7:0] <= billAccWire[7:0];
				end
			17: begin 				 
				uartDataReg <= "\r";

				end
			18: begin
				uartDataReg <= "\n";				
				regsChanged <= 0;
				oneWireTemperatureL[7:0] <= oneWireTemperature[7:0];
				 end
			default: begin
				uartDataReg <= 0;
				uartEna <= 0;
				//oneWireTemperatureL <= oneWireTemperature;
			end
		endcase	
	end		
	else begin 			
		uartStartSignal <= 1'b0;
		//SYNCHRO <= 0;
	end
	
	
	
	if(uartRxDataReady) begin		
		//USER_LED0 <= ~USER_LED0;		
		//USER_LED1 <= ~USER_LED1;	
		//uartDataReg1 <= uartRxData;
	end
	
	if(enc1PosLast != enc1Pos) begin
		enc1PosLast <= enc1Pos;
		regsChanged <= 1;
	end
	if(enc2PosLast != enc2Pos) begin
		enc2PosLast <= enc2Pos;
		regsChanged <= 1;
	end
	
end
 


endmodule
