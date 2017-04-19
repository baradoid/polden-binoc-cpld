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
output   [ 35: 7] 	BGPIO,
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
					 .start(tempMeasStart),
					 .oneWirePin(BGPIO_ONEWIRE),
					 //.oneWirePinOut(BGPIO_ONEWIRE),
					 .temperature(oneWireTemperature),
					 .readState(BGPIO[33]));

//bv_controller bv_contr_inst(.CLK_10MHZ(CLK_SE_AR),
//									 .uartRxPin(BGPIO[28]),
//									 .uartTxPin(BGPIO[26]),
//									 .billAccumed(billAccWire));
wire [7:0] billAccWire;
										

wire oneWireOutput;
//OPNDRN opdn (.in(oneWireOutput), .out(BGPIO_ONEWIRE));
					 
//reg [23:0] clockDivider = 0;
reg [23:0] clockCntStart = 0;
reg [23:0] tempMeasStartCnt = 0;


wire [15:0] oneWireTemperature;
wire [23:0] data;

					 
spi spi_AdcInst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[32]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(adcStart),
				 .miso(BGPIO[30]),				 
				 //.data_in(spiDataIn),
				 .data_out(spiDataOut),
				 .new_data(spiNewData));
				 
reg [7:0] spiDataIn; 
wire [7:0] spiDataOut;
wire spiNewData;
reg adcStart;

spi spi_enc1Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[28]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(adcStart),
				 .miso(BGPIO[26]),				 
				 //.data_in(spiDataIn),
				 .data_out(enc1Pos),
				 .new_data(enc1NewData));

spi spi_enc2Inst(.clk(CLK_SE_AR),
				 .rst(1'b0),
				 .sck(BGPIO[25]),
				 //.mosi(BGPIO_SPI_MOSI),
				 .start(adcStart),
				 .miso(BGPIO[22]),				 
				 //.data_in(spiDataIn),
				 .data_out(enc2Pos),
				 .new_data(enc2NewData));
				 
wire [11:0] enc1Pos, enc2Pos;				 
wire enc1NewData, enc2NewData;

reg start, startL;
reg tempMeasStart=0;

wire uartStartSignal = ((start==0)&&(startL==1)&&(uartEna==1));
wire uartPrepDataSignal = ((start==1)&&(startL==0));

//reg [7:0] data;
reg [7:0] dataIn;
wire newDataWire;
wire [7:0] spiDataWire;
wire uartBusy;
reg uartEna = 0;

//reg[8*16:1] str ="abcd01234";

assign BGPIO[35] = tempMeasStart;
//assign BGPIO[33] = uartStartSignal;
assign BGPIO[31] = uartPrepDataSignal;

reg [7:0] uartDataReg;
reg [7:0] uartDataReg1;
//assign uartData = str[8:1];


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
	
	if(clockCntStart == 24'd10000) begin
		start <= 1'b1;
		adcStart <= 1'b1;
		clockCntStart <= 0;	
	end
	else begin
		clockCntStart <= clockCntStart + 24'd1;			
		start <= 1'b0;
		adcStart <= 1'b0;
	end
	
	if(tempMeasStartCnt == 24'd5000000) begin		
		tempMeasStartCnt <= 0;	
		tempMeasStart <= 1'b1;
	end
	else begin
		tempMeasStartCnt <= tempMeasStartCnt + 24'd1;			
		tempMeasStart <= 1'b0;
	end
	
	
	if(newDataWire) begin
		dataIn <= spiDataWire;	
	end
	
	startL <= start;
	if(uartPrepDataSignal) begin 
		uartState <= uartState + 5'd1;
		case(uartState)
			0: begin 
				uartDataReg <= "a";	
				uartEna <= 1;
				end
			1: uartDataReg <= enc1Pos;
			2: uartDataReg <= enc1Pos;
			3: uartDataReg <= enc1Pos;
			4: uartDataReg <= " ";
			
			5: uartDataReg <= enc2Pos;  //dallas
			6: uartDataReg <= enc2Pos;
			7: uartDataReg <= enc2Pos;			
			8: uartDataReg <= " ";						
			9: uartDataReg <= (oneWireTemperature[7:4]<4'hA)? (oneWireTemperature[7:4]+8'h30):(oneWireTemperature[7:4]+8'h37);
			10: uartDataReg <= (oneWireTemperature[3:0]<4'hA)? (oneWireTemperature[3:0]+8'h30):(oneWireTemperature[3:0]+8'h37);
			11: uartDataReg <= " ";
			12: uartDataReg <= uartDataReg1;
			13: uartDataReg <= "s";
			14: uartDataReg <= "g";
			15: uartDataReg <= "h";			
			16: uartDataReg <= " ";
			17: uartDataReg <= "k";
			18: uartDataReg <= "l";								
			19: uartDataReg <= " ";
			20: uartDataReg <= "m";
			21: uartDataReg <= billAccWire;
			22: uartDataReg <= billAccWire;
			23: uartDataReg <= "s";
				
			
			//4: uartDataReg <= (oneWireTemperature[11:8]<4'hA)? (oneWireTemperature[11:8]+8'h30):(oneWireTemperature[11:8]+8'h37);		
			//5: uartDataReg <= (oneWireTemperature[15:12]<4'hA)? (oneWireTemperature[15:12]+8'h30):(oneWireTemperature[15:12]+8'h37);		
			//6: uartDataReg <= oneWireTemperature[15:8];		
			//7: uartDataReg <= oneWireTemperature[7:0];		
			
			//2: uartDataReg <= (oneWireTemperature[3:0]<4'hA)? (oneWireTemperature[3:0]+8'h30):(oneWireTemperature[3:0]+8'h37);		
			24: uartDataReg <= "\r";
			25: uartDataReg <= "\n";	
			default: begin
				uartDataReg <= 0;
				uartEna <= 0;
			end
		endcase			
	end	
	
	
	
	if(uartRxDataReady) begin		
		USER_LED0 <= ~USER_LED0;		
		USER_LED1 <= ~USER_LED1;	
		uartDataReg1 <= uartRxData;
	end
end
 


endmodule
