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

	// Clk gen (fclk = 50MHz)
	reg clk_f = 28'h2FAF080;
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
	end	
//------END SETUP------//

//------BEGIN PARAM & VAR------//
	///Parameters for algorithms given by TA's///
	wire swiptAlive;

	///Data Sending Ready
    wire data_go = 0;
	reg data_go_reg = 0;

    ///Freq Varibles
    reg [19:0] freq = 20'h9C40; //Default freq is 40 000 Hz
    reg [19:0] delta_freq = 20'h64; //Delta freq is 100 Hz but can be modified (max 255Hz for 8 bits)
    wire freq_optimum = 1'b0; //Default no optimum
	wire freq_rdy = 1'b0; //Default 0
    wire freq_set_up_down = 1'b1; //Default up

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

//------BEGIN SWIPT_OUTX------//

    ///Set SWIPT_OUTX
    reg s0 = 0; //left-up
    reg s1 = 0; //right-up
    reg s2 = 0; //left-down
    reg s3 = 0; //right-down

    //Pulselength is the time (#clk_cycles) that a MOS is high --> can change to 20% if data is transfered
    //Default is x% of duty cycle with x given by the power optimization algorithm
    //If we use a specific kind of data transmission (ex: 0V,2.5V and 5V) this is also possible by setting the pulse time on different lenghts
    reg [11:0] pulse_length; //Default pulse-length 48% for now

    reg [11:0] pulse_counter; //Is in default about 12 clk_cycli shorter than counter_half
    reg [11:0] counter_half;
    reg [12:0] counter_full;

    always @(posedge clk)begin
        if(~nrst)begin
            //Reset
			pulse_length <= (clk_f/freq)/2 - (clk_f/freq)/50;
			pulse_counter <= pulse_length;
			counter_half <= clk_f/freq/2;
			counter_full <= clk_f/freq;

            s0 <= 0;
            s1 <= 0;
            s2 <= 1;
            s3 <= 1; 
        end

        else begin
            if(pulse_counter == 0 && counter_half == 0)begin
                //Half the duty cycle is done --> inverse
                if(counter_full == 0 || counter_full == 1)begin
                   s0 <= 1;
                   s1 <= 0;
                   s2 <= 0;
                   s3 <= 1;
                   counter_full <= clk/freq - 1;
                end
                else begin
                   s0 <= 0;
                   s1 <= 1;
                   s2 <= 1;
                   s3 <= 0; 
                end
                counter_half <= clk/freq/2 - 1;
                pulse_counter <= pulse_length - 1;
            end
            else if(pulse_counter == 0)begin
                //Pulse time is over --> set uppers to 1 and lowers to 0
                s0 <= 0;
                s1 <= 0;
                s2 <= 1;
                s3 <= 1;

                counter_half <= counter_half - 1;
                counter_full <= counter_full - 1;
            end
            else begin
                counter_half <= counter_half - 1;
                counter_full <= counter_full - 1;
                pulse_counter <= pulse_counter - 1;
            end
        end
    end
//------END SWIPT_OUTX------//

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
            .freq_rdy (freq_rdy),
            .freq_set_up_down (freq_set_up_down),
            .freq_opt (freq_optimum)
			);

//------END MODULES------//

//------BEGIN ASSIGN OUTPUT------//
	assign SWIPT_OUT0 = s0;
	assign SWIPT_OUT1 = s1;
	assign SWIPT_OUT2 = s2;
	assign SWIPT_OUT3 = s3;

	//Input of analog circuit
	wire IN_DIGITAL;
	//Output of analog cicuit
	wire OUT_DIGITAL;
	
	//Input of the analog part is the MSB of the counter value
	assign IN_DIGITAL = value[11];
	assign ADC_in = value;

//------END ASSIGN OUTPUT------//

//------BEGIN ANALOG PART------//

	//Analog circuit
	ANALOG_NETWORK inst_ANALOG_NETWORK (
		.IN_DIGITAL		(IN_DIGITAL),
		.OUT_DIGITAL	(OUT_DIGITAL)
		);

//------END ANALOG PART------//
endmodule
