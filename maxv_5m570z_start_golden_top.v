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
 
one_wire(
 .clk(oneWireClock),
 .reset(oneWireReset),
 .wire_out(BGPIO_ONEWIRE),
 .wire_in(BGPIO_ONEWIRE),
 .in_byte(oneWireByteBufIn[7:0]),
 .out_byte(oneWireByteBufOut[7:0]),
 .read_byte(oneWireRead),
 .write_byte(oneWireWrite),
 .busy(oneWireBusy)
);

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
																					.TxD_start(start), 
																					.TxD_data(uartDataReg),
																					.TxD_busy(uartBusy));

async_transmitter #(.ClkFrequency(10000000), .Baud(19200)) TXBV(.clk(CLK_SE_AR), .TxD(BGPIO[30]), .TxD_start(start), .TxD_data(uartDataReg));

integer clockDivider = 0;
integer clockCntStart = 0;
integer clockOneWireDivider = 0;

integer oneWireDelay = 0;

reg oneWireClock=0, oneWireReset=0, oneWireRead=0, oneWireWrite=0;
reg [7:0] oneWireByteBufIn;
reg [7:0] oneWireByteBufOut;
reg [7:0] oneWireByteScrPad[9:0];
reg [3:0] oneWireByteScrPadInd;
wire oneWireBusy;
reg oneWireBusyLast;
reg oneWireBusyLastLast;

assign BGPIO[33] = oneWireBusy;

reg start;
//reg [7:0] data;
reg [7:0] dataIn;
wire newDataWire;
wire [7:0] spiDataWire;
wire uartBusy;

//reg[8*16:1] str ="abcd01234";

assign BGPIO[35] = start;

reg [7:0] uartDataReg;
//assign uartData = str[8:1];

assign BGPIO[32] = oneWireClock;

always @(posedge CLK_SE_AR) begin
			
	if(clockDivider == 10000000) begin
		clockDivider = 0;		
		USER_LED0 = ~USER_LED0;
		USER_LED1 = ~USER_LED1;
	end
	else begin
		clockDivider = clockDivider + 1;			
	end
	
	if(clockCntStart == 1000000) begin
		start <= 1'b1;
		//data <= data + 1;
		clockCntStart <= 0;	
		//str[8*16:1] <= {str[8*16:9], str[8:1]};
	end
	else begin
		clockCntStart <= clockCntStart + 1;			
		start <= 1'b0;
	end
	
	if(newDataWire) begin
		dataIn <= spiDataWire;	
	end
	
		
	if(clockOneWireDivider == 59) begin
		clockOneWireDivider <= 0;	
		oneWireClock <= 1;
	end
	else begin
		clockOneWireDivider <= clockOneWireDivider + 1;					
		oneWireClock <= 0;
	end
end

parameter idle=0, state0=1, state1=2, state2=3, state3=4, state4=5, state5=6;
reg [2:0] state_e;

parameter oneWireIdleState=0, oneWireResetState=1, oneWireSkipRomCmd=2, oneWireReadScrPadCmd=3, oneWireReadScrPad=4, oneWireConvertCmd=5, oneWireWaitConvertOk=6;
reg [2:0] oneWireState_e = oneWireIdleState;

always @(posedge CLK_SE_AR) begin
	
	case(state_e)
		idle: uartDataReg <= "a";	
		state1: uartDataReg <= "b";
		state2: uartDataReg <= oneWireByteScrPad[0];		
		state3: uartDataReg <= oneWireByteScrPad[1];		
		state4: uartDataReg <= "\r";
		state5: uartDataReg <= "\n";			
	endcase	

	if(start) begin 
		case(state_e)
			idle:   state_e <= state1;	
			state1: state_e <= state2;		
			state2: state_e <= state3;
			state3: state_e <= state4;	
			state4: state_e <= state5;	
			state5: state_e <= idle;	
		endcase	
	end
	
	
	oneWireBusyLastLast <= oneWireBusyLast;
	oneWireBusyLast <= oneWireBusy;
	
	if(oneWireState_e == oneWireIdleState) begin		
		if(start) begin			
			oneWireState_e <= oneWireResetState;								
		end	
	end
	else if(oneWireState_e == oneWireResetState) begin
		if((oneWireBusy==0) && (oneWireBusyLast==0)) begin
			oneWireReset <= 1;		
		end
		if((oneWireBusy==1)&&(oneWireBusyLast==0)) begin
			oneWireReset <= 0;											
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==1)) begin
			oneWireState_e <= oneWireSkipRomCmd;	
			//oneWireState_e <= oneWireIdleState;					
		end		
	end
	else if(oneWireState_e == oneWireSkipRomCmd) begin
		if((oneWireBusy==0) && (oneWireBusyLast==0)) begin
			oneWireWrite <= 1;		
			oneWireByteBufIn <= 8'hCC;
		end
				
		if((oneWireBusy==1)&&(oneWireBusyLast==0)) begin
			oneWireWrite <= 0;	
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==1)) begin
			oneWireState_e <= oneWireConvertCmd;		
			//oneWireState_e <= oneWireIdleState;					
		end	
	end	
	else if(oneWireState_e == oneWireConvertCmd) begin	
		if((oneWireBusy == 0)&&(oneWireBusyLast==0)) begin
			oneWireWrite <= 1;		
			oneWireByteBufIn <= 8'h44;			
		end
		if((oneWireBusy==1)&&(oneWireBusyLast==0)) begin
			oneWireWrite <= 0;	
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==1)) begin
			oneWireState_e <= oneWireReadScrPadCmd;		
		end
	end	


	else if(oneWireState_e == oneWireWaitConvertOk) begin	
		if((oneWireBusy == 0)&&(oneWireBusyLast==0)&&(oneWireBusyLastLast==0)) begin
			oneWireRead <= 1;					
		end
		if((oneWireBusy==1)&&(oneWireBusyLast==0)&&(oneWireBusyLastLast==0)) begin
			oneWireRead <= 0;	
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==0)&&(oneWireBusyLastLast==1)) begin
			if(oneWireByteBufOut == 1) begin
				oneWireState_e <= oneWireReadScrPadCmd;				
			end			
		end
	end	

	
	
	else if(oneWireState_e == oneWireReadScrPadCmd) begin
		if((oneWireBusy==0) && (oneWireBusyLast==0)) begin
			oneWireWrite <= 1;		
			oneWireByteBufIn <= 8'hBE;
		end
		if((oneWireBusy==1)&&(oneWireBusyLast==0)) begin
			oneWireWrite <= 0;							
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==1)) begin
			oneWireByteScrPadInd <= 0;
			oneWireState_e <= oneWireReadScrPad;		
			//oneWireState_e <= oneWireIdleState;
		end
	end	
	else if(oneWireState_e == oneWireReadScrPad) begin
		if((oneWireBusy == 0)&&(oneWireBusyLast==0)) begin
			oneWireRead <= 1;					
		end
		if((oneWireBusy==1)&&(oneWireBusyLast==0)) begin
			oneWireRead <= 0;											
		end
		if((oneWireBusy==0)&&(oneWireBusyLast==1)) begin
			oneWireByteScrPad[oneWireByteScrPadInd] <= oneWireByteBufOut;		
			oneWireByteScrPadInd <= oneWireByteScrPadInd + 1;
			if(oneWireByteScrPadInd == 9) begin
				oneWireState_e <= oneWireIdleState;	
			end
		
		end

	end	

	
	


	
	
 end
 


endmodule
