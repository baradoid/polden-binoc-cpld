/* maxv_5m570z_start_golden_top.v
 This is a top level wrapper file that instanciates the
 golden top project
 */
 
 module maxv_5m570z_start_golden_top(
 
input   CLK_SE_AR,

// GPIO
input USER_PB0, USER_PB1,
input CAP_PB_1,
output reg USER_LED0, USER_LED1,

// Connector A 
output   [  36: 1] 	AGPIO,

// Connector B
inout    BGPIO_ONEWIRE,
//input    BGPIO_SPI_MISO,
//input    BGPIO_SPI_CLK,
input 	BGPIO_UART_RX,
output 	BGPIO_UART_TX,
output   [ 30: 7] 	BGPIO,
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

reg [31:0] timerCounter; always @(posedge CLK_SE_AR) timerCounter <= timerCounter + 31'h1;
assign BGPIO[30] = timerCounter[31];

wire uartBusy;
reg [7:0] uartBusyR; always @(posedge CLK_SE_AR) uartBusyR[7:0] <= {uartBusyR[6:0], uartBusy};
reg uartEna = 0;
reg uartStartSignal = 0;
//wire uartPrepDataSignal = ((uartBusy==0)&&(uartBusyR==1));
wire uartTxFree = (uartTxFree==8'h0);


reg [7:0] uartDataReg;

async_transmitter #(.ClkFrequency(10000000), .Baud(230400)) TX(.clk(CLK_SE_AR),
																					//.BitTick(uartTick1),
																					.TxD(BGPIO_UART_TX), 
																					.TxD_start(uartStartSignal), 
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
																					
dallas18b20Ctrl dallas18b20Ctrl_inst(.CLK_10MHZ(CLK_SE_AR),
					 //.start(tempMeasStart),
					 .oneWirePin(BGPIO_ONEWIRE),
					 //.oneWirePinOut(BGPIO_ONEWIRE),
					 .temperature(oneWireTemperature)/*,
					 .readState(BGPIO[33])*/);

bv_controller bv_contr_inst(.CLK_10MHZ(CLK_SE_AR),
									 .uartRxPin(BGPIO[28]),
									 .uartTxPin(BGPIO[26]),
									 .billAccumed(billAccWire));
wire [7:0] billAccWire;
										

wire oneWireOutput;
//OPNDRN opdn (.in(oneWireOutput), .out(BGPIO_ONEWIRE));
					 
//reg [23:0] clockDivider = 0;
//reg [23:0] clockCntStart = 0;
//reg [23:0] tempMeasStartCnt = 0;


wire [7:0] oneWireTemperature;
wire [23:0] data;

					 


//reg adcStart;
reg spi1BusyR, spi2BusyR, spiAdcBusyR; 
wire spi1Busy, spi2Busy,  spiAdcBusy;

always @(posedge CLK_SE_AR) begin
	spi1BusyR <= spi1Busy;
	spi2BusyR <= spi2Busy;
	spiAdcBusyR <= spiAdcBusy;
end

wire spi1Start = ((spi1Busy==1'b0)&&(spi1BusyR==1'b0));
wire spi2Start = ((spi2Busy==1'b0)&&(spi2BusyR==1'b0));
wire spiAdcStart = ((spiAdcBusy==1'b0)&&(spiAdcBusyR==1'b0));

spi spi_enc1Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[28]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(spi1Start),
				 .miso(BGPIO[26]),				 
				 //.data_in(spiDataIn),
				 .data_out(enc1Pos),
				 .new_data(enc1NewData));

spi spi_enc2Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[25]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(spi2Start),
				 .miso(BGPIO[22]),				 
				 //.data_in(spiDataIn),
				 .data_out(enc2Pos),
				 .new_data(enc2NewData));

spi spi_AdcInst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[24]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(spiAdcStart),
				 .miso(BGPIO[20]),				 
				 //.data_in(spiDataIn),
				 .data_out(adcData),
				 .new_data(spiNewData));
				 

wire [7:0] adcData;
wire spiNewData;
				 
wire [11:0] enc1Pos, enc2Pos;				 
wire enc1NewData, enc2NewData;

reg [7:0] dataIn;
wire newDataWire;
wire [7:0] spiDataWire;



reg [3:0] transDataIn;
wire [7:0] transDataOut = (transDataIn[3:0]<4'hA)? (transDataIn[3:0]+8'h30):(transDataIn[3:0]+8'h37);

reg [4:0] uartState = 0;

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
	
	if(uartTxFree) begin 
		uartState <= uartState + 5'd1;
		uartStartSignal <= 1'b1;				
		case(uartState)
			0: begin 				
				uartEna <= 1;
				transDataIn <= enc1Pos[11:8];
				//uartDataReg <= " ";
				uartDataReg <= "A";
				
				end
			1: begin 
				transDataIn <= enc1Pos[7:4]; 
				//uartDataReg <= transDataOut;
				uartDataReg <= "B";					
				end 
			2: begin 
				transDataIn <= enc1Pos[3:0];
				//uartDataReg <= transDataOut;
				uartDataReg <= "C";				
				end
			3: begin
				//uartDataReg <= transDataOut;
				uartDataReg <= "D";				
				end
			4: begin
				transDataIn <= enc2Pos[11:8];
				//uartDataReg <= " ";
				uartDataReg <= "E";				
				end			
			5: begin
				transDataIn <= enc2Pos[7:4]; 
				//uartDataReg <= transDataOut;
				uartDataReg <= "F";				
				end
			6: begin
				transDataIn <= enc2Pos[3:0];				
				uartDataReg <= transDataOut;  //dallas			
				end
			7: begin 
				uartDataReg <= enc2Pos[3:0];						
				end
			8: begin 
				uartDataReg <= " ";						
				transDataIn <= oneWireTemperature[7:4];
				
				end
			9: begin
				transDataIn <= oneWireTemperature[3:0];
				uartDataReg <= transDataOut;			
				end
			10: begin				
				uartDataReg <= transDataOut;				
				end
			11: begin
				uartDataReg <= " ";			
				end
			12: begin
				uartDataReg <= " ";			
				end
			
			13: begin 				 				 
				 uartDataReg <= " ";			
				 end
			14: begin 
				 transDataIn <= billAccWire[7:4];				 
				 uartDataReg <= transDataOut;			
				 end
			15: begin
				 transDataIn <= billAccWire[3:0];				 
				 uartDataReg <= transDataOut;			
				 end
			16: begin
				 uartDataReg <= transDataOut;			
				 end				 								
			17: begin 
				 uartDataReg <= "\r";			
				 end
			18: begin 
				 uartDataReg <= "\n";				
				 end
			default: begin
				uartDataReg <= 0;
				uartEna <= 0;
			end
		endcase			
	end
	else begin
		uartStartSignal <= 1'b0;
	end
	
	
	
	if(uartRxDataReady) begin		
		USER_LED0 <= ~USER_LED0;		
		USER_LED1 <= ~USER_LED1;	
		//uartDataReg1 <= uartRxData;
	end
end
 


endmodule
