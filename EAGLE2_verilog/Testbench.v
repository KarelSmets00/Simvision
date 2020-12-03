`timescale 1ps/1ps


module toplevel ();
//------BEGIN SETUP------//
	//Parameter given by zybo (for now they are not perfectly right)
	reg clk = 2'b1;
	reg nrst = 1'b0;
	reg swiptONHeartbeat = 1'b1;
	wire [11:0] value;
	wire [11:0] ADC_in; //for now this is a generated parameter, wich is the same as 'value'

	wire SWIPT_OUT0;
	wire SWIPT_OUT1;
	wire SWIPT_OUT2;
	wire SWIPT_OUT3;

	reg [19:0] freq = 20'h9C40; //Default freq is 40 000 Hz
	// Clk gen (fclk = 50MHz)
	//reg [27:0] clk_f = 28'h2FAF080;
	always #10000 clk = ~clk;
	//always #10000 swiptONHeartbeat <= ~swiptONHeartbeat;
	
	always @(posedge clk)begin
		if(value == 0)begin
			swiptONHeartbeat <= ~swiptONHeartbeat;
		end
	end

	// Reset
	initial begin
		#100000 nrst = 1'b1;
		//#50000000000 freq = 20'h7530;
	end	
//------END SETUP------//

//------BEGIN PARAM & VAR------//
	///Parameters for algorithms given by TA's///
	wire swiptAlive;

	///Data Sending Ready
    wire data_go = 0;
	reg data_go_reg = 0;

    ///Freq Varibles
    reg [19:0] delta_freq = 20'h64; //Delta freq is 100 Hz but can be modified (max 255Hz for 8 bits)
    wire freq_optimum; //Default no optimum
	wire freq_rdy; //Default 0
    wire freq_set_up_down; //Default up

    ///Power Variables
    wire power_optimum = 0; //Default no power optimum

//------END PARAM & VAR------//

//------BEGIN OPTIMIZATION ALG.------//
	///Optimization Algorithm
    always @(posedge clk)begin
		if(swiptAlive && ~nrst)begin
			//If Swipt is alive check if freq is ok
		    if(~freq_optimum)begin
		        data_go_reg <= 0;
		        //If freq optimum not reached, rerun the algorithm

		        //If the algorithm set the freq_rdy var to 1 --> change the freq with the default amount
		        if(freq_rdy == 1)begin
		            //If freq_set_up_down --> then the the freq must be higer
		            if(freq_set_up_down)begin
		                freq <= freq + delta_freq;
		            end
		            //Else the freq must be lower
		            else begin
		                freq <= freq - delta_freq;
		            end
		        end
		    end
		    
		    //If freq is ok --> optimize power
		    else if(~power_optimum)begin
		        data_go_reg <= 0;

		        //If power optimum is not reached, run optimization algorithm
		        $display("freq done -- power now");
		    end

		    //If power and freq are optimized, start data transfer
		    else begin
		        data_go_reg <= 1;
		    end
		end
    end
	assign data_go = data_go_reg;
//------END OPTIMIZATION ALG.------//

//------BEGIN MODULES------//
	
	//set swipt alive
	Heartbeat inst_heartbeat (
			.clk (clk),
			.nrst (nrst),
			.swiptONHeartbeat (swiptONHeartbeat),
			.swipt (swiptAlive)
			);

	//counter instance
	Counter inst_counter (
			.clk (clk),
			.nrst (nrst),
			.value (value)
			);
	
	//freq optimization algorithm
	Freq inst_freq (
			.clk (clk),
            .nrst (nrst),
            .ADC_in (ADC_in),
            .freq_ready (freq_rdy),
            .freq_set_up_down (freq_set_up_down),
            .freq_opt (freq_optimum)
			);

	SwiptOut inst_swiptout (
			.clk (clk),
			.nrst (nrst),
			.freq (freq),
			.SWIPT_OUT0 (SWIPT_OUT0),
			.SWIPT_OUT1 (SWIPT_OUT1),
			.SWIPT_OUT2 (SWIPT_OUT2),
			.SWIPT_OUT3 (SWIPT_OUT3)
			);

//------END MODULES------//

//------BEGIN ASSIGN OUTPUT------//
	wire ADC0;
	wire ADC1;
	wire ADC2;
	wire ADC3;
	wire ADC4;
	wire ADC5;
	wire ADC6;
	wire ADC7;
	wire ADC8;
	wire ADC9;
	wire ADC10;
	wire ADC11;


//------END ASSIGN OUTPUT------//

//------BEGIN ANALOG PART------//

	//Analog circuit
	ANALOG_NETWORK inst_ANALOG_NETWORK (
		.SWIPT_OUT0	(SWIPT_OUT0),
		.SWIPT_OUT1	(SWIPT_OUT1),
		.SWIPT_OUT2 (SWIPT_OUT2),
		.SWIPT_OUT3 (SWIPT_OUT3),
		.ACOUT0 (ADC11),
		.ACOUT1 (ADC10),
		.ACOUT2 (ADC9),
		.ACOUT3 (ADC8),
		.ACOUT4 (ADC7),
		.ACOUT5 (ADC6),
		.ACOUT6 (ADC5),
		.ACOUT7 (ADC4),
		.ACOUT8 (ADC3),
		.ACOUT9 (ADC2),
		.ACOUT10 (ADC1),
		.ACOUT11 (ADC0)
		);

	
	assign ADC_in[11] = ADC11;
	assign ADC_in[10] = ADC10;
	assign ADC_in[9] = ADC9;
	assign ADC_in[8] = ADC8;
	assign ADC_in[7] = ADC7;
	assign ADC_in[6] = ADC6;
	assign ADC_in[5] = ADC5;
	assign ADC_in[4] = ADC4;
	assign ADC_in[3] = ADC3;
	assign ADC_in[2] = ADC2;
	assign ADC_in[1] = ADC1;
	assign ADC_in[0] = ADC0;
//------END ANALOG PART------//
endmodule
