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
output   [  35: 7] 	BGPIO,
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
 
 reg [7:0] outByte;
 
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


async_transmitter #(.ClkFrequency(10000000), .Baud(115200)) TX(.clk(CLK_SE_AR), 
																					.TxD(BGPIO[34]), 
																					.TxD_start(uartStartSignal), 
																					.TxD_data(uartDataReg),
																					.TxD_busy(uartBusy));

async_transmitter #(.ClkFrequency(10000000), .Baud(19200)) TXBV(.clk(CLK_SE_AR), 
																					 .TxD(BGPIO[30]), 
																					 .TxD_start(start), 
																					 .TxD_data(uartDataReg));


dallas18b20Ctrl(.CLK_10MHZ(CLK_SE_AR),
					 .start(tempMeasStart),
					 .oneWirePinIn(BGPIO_ONEWIRE),
					 .oneWirePinOut(oneWireOutput),
					 .temperature(oneWireTemperature),
					 .data(data));

wire oneWireOutput;
OPNDRN opdn (.in(oneWireOutput), .out(BGPIO_ONEWIRE));
					 
integer clockDivider = 0;
integer clockCntStart = 0;
integer tempMeasStartCnt = 0;


wire [15:0] oneWireTemperature;
wire [23:0] data;



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
assign BGPIO[33] = uartStartSignal;
assign BGPIO[31] = uartPrepDataSignal;

reg [7:0] uartDataReg;
//assign uartData = str[8:1];


reg [3:0] uartState = 0;

always @(posedge CLK_SE_AR) begin
			
	if(clockDivider == 10000000) begin
		clockDivider = 0;		
		USER_LED0 = ~USER_LED0;
		USER_LED1 = ~USER_LED1;
	end
	else begin
		clockDivider = clockDivider + 1;			
	end
	
	if(clockCntStart == 500000) begin
		start <= 1'b1;
		clockCntStart <= 0;	
	end
	else begin
		clockCntStart <= clockCntStart + 1;			
		start <= 1'b0;
	end
	
	if(tempMeasStartCnt == 20000000) begin		
		tempMeasStartCnt <= 0;	
		tempMeasStart <= 1'b1;
	end
	else begin
		tempMeasStartCnt <= tempMeasStartCnt + 1;			
		tempMeasStart <= 1'b0;
	end
	
	
	if(newDataWire) begin
		dataIn <= spiDataWire;	
	end
	
	startL <= start;
	if(uartPrepDataSignal) begin 
		uartState <= uartState + 1;
		case(uartState)
			0: begin 
				uartDataReg <= "a";	
				uartEna <= 1;
				end
			1: uartDataReg <= "b";
			2: uartDataReg <= oneWireTemperature[7:0];		
			3: uartDataReg <= oneWireTemperature[15:8];		
			4: uartDataReg <= data[7:0];		
			5: uartDataReg <= data[15:8];		
			6: uartDataReg <= data[23:16];		
			7: uartDataReg <= "\r";
			8: uartDataReg <= "\n";	
			default: begin
				uartDataReg <= 0;
				uartEna <= 0;
			end
		endcase			
	end	
 end
 


endmodule
