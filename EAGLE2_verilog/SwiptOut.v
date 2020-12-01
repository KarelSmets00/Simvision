`timescale 1ps/1ps

module SwiptOut (
	input wire clk,
	input wire nrst,
	input wire [19:0] freq,
	output wire SWIPT_OUT0,
	output wire SWIPT_OUT1,
	output wire SWIPT_OUT2,
	output wire SWIPT_OUT3
	);

	reg [27:0] clk_f = 28'h2FAF080;
	reg checkStart = 1'b0;
	reg [3:0] deadTimeL = 4'hE;
	reg [3:0] dead_counter = 4'hE;
	reg dead = 1'b1;
    ///Set SWIPT_OUTX
    reg s0 = 0; //left-up
    reg s1 = 0; //right-up
    reg s2 = 1; //left-down
    reg s3 = 1; //right-down

    //Pulselength is the time (#clk_cycles) that a MOS is high --> can change to 20% if data is transfered
    //Default is x% of duty cycle with x given by the power optimization algorithm
    //If we use a specific kind of data transmission (ex: 0V,2.5V and 5V) this is also possible by setting the pulse time on different lenghts
	reg [3:0] l = 4'h3;//this is the parameter that is used to define the length of the pulse.
	
	//always begin
		//l = 4'h3;
		//#(1000000000);
		//l = 4'h5;
		//#(1000000000);
	//end

    reg [11:0] pulse_length; //Default pulse-length 48% for now
	//pulse_length <= (clk_f/freq)/2 - (clk_f/freq)/50; //This will be deleted when de data module is launched

    reg [11:0] pulse_counter; //Is in default about 12 clk_cycli shorter than counter_half
    reg [11:0] counter_half;
    reg [12:0] counter_full;

    always @(posedge clk)begin
        if(~nrst)begin
            //Reset
			pulse_length <= clk_f/freq/l;
			pulse_counter <= clk_f/freq/l;
			counter_half <= clk_f/freq/2;
			counter_full <= clk_f/freq;
			checkStart <= 0;
			dead <= 1;
			

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
                	counter_full <= clk_f/freq - 1;
					counter_half <= clk_f/freq/2 - 1;
					pulse_length <= clk_f/freq/l;
					pulse_counter <= clk_f/freq/l - 1;
                end
                else begin
                	s0 <= 0;
                	s1 <= 1;
                	s2 <= 1;
                	s3 <= 0;
					counter_half <= counter_full -1;
					pulse_counter <= pulse_length - 1;
                end
            end
            else if(pulse_counter == 0)begin
                //Pulse time is over --> set uppers to 0 and lowers to 1 aka circuit to GND
                s0 <= 0;
                s1 <= 0;
                s2 <= 1;
                s3 <= 1;

                counter_half <= counter_half - 1;
                counter_full <= counter_full - 1;
				dead <= 0;

            end
            else begin
				checkStart <= 1'b1;
				if(checkStart == 0)begin
					s0 <= 1;
          			s1 <= 0;
		            s2 <= 0;
		            s3 <= 1;
				end
				else begin
					s0 <= s0;
		            s1 <= s1;
		            s2 <= s2;
		            s3 <= s3;
				end
                counter_half <= counter_half - 1;
                counter_full <= counter_full - 1;
                pulse_counter <= pulse_counter - 1;
				
				if(dead_counter == 0)begin
					dead <= 0;
				end
				else begin
					dead_counter <= dead_counter - 1;
				end
            end

			//Extra parameter counter reset if half cycle swipt
			if(counter_half == 12'h001) begin
				dead_counter <= deadTimeL;
				dead <= 1;
			end
			else if(pulse_counter - deadTimeL == 1)begin
				dead_counter <= deadTimeL;
				dead <= 1;
			end
        end
    end
	
	assign SWIPT_OUT0 = s0 & ~dead;
	assign SWIPT_OUT1 = s1 & ~dead;
	assign SWIPT_OUT2 = s2;
	assign SWIPT_OUT3 = s3;

endmodule
