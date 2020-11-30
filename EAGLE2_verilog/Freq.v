`timescale 1ps/1ps

module Freq (
	input wire clk,
	input wire nrst,
	input wire [11:0] ADC_in,
	output wire freq_rdy,
	output reg freq_set_up_down,
	output reg freq_opt
	);

	reg freq_ready = 1'b0;
	//reg freq_set_up_down;
	//reg freq_opt;	

	//For this algorithm, we will calculate the maximum current
    reg [11:0] old_highest = 12'h000;
    reg [11:0] new_highest = 12'h000;
    
    //clk = 50MHz; Samp = 1MHz; Power ~= 40khz --> #clk_cycl/period_power ~= 50*25 = 1250 clk_cycli/power_cyclus
    //If we choose around 4 power_cycli to messure --> clk_counter = 4*1250 = 5000
    reg [15:0] clk_cycles = 16'h1388; //Every highest messurement is done over 5000 clk_cycles

    reg [2:0] threshold = 12'b101; //Treshhold is default 5/2048 = 0,244 % - Can be modified (2048 = 11bit = 12'h7FF)
    
    always @(posedge clk)begin

        //Reset
        if(~nrst)begin
            freq_ready <= 0;
            freq_set_up_down <= 1; //Default is up
            freq_opt <= 0; //Default is no optimum
            clk_cycles <= 16'h1388;
            old_highest <= 12'h000;
            new_highest <= 12'h000;
        end
        
        //If the counter is set zero --> compare old_highest to new_highest
        else if(clk_cycles == 0)begin
            
            //Compare highest value of previous messurement to the new messurement : 
            //duration: 5000 clk_cycles each
            old_highest <= new_highest - 10;
			new_highest <= 12'h000;
            clk_cycles <= 16'h1388;

            if(old_highest < new_highest)begin
                //Right direction
				$display("right dir");

                //Check optimum
                if(new_highest - old_highest < threshold)begin
                    //We found an optimum --> end freq optimization algorithm
                    freq_opt <= 1;
					freq_ready <= 0;
                    freq_set_up_down <= freq_set_up_down;
                end

                //No optimum
                else begin
                    freq_set_up_down <= ~freq_set_up_down;
                    freq_ready <= 1;
					freq_opt <= 0;
                end
            end

            else if(old_highest > new_highest)begin
                //Wrong direction
				$display("wrong");

                //Check optimum
                if(old_highest - new_highest < threshold)begin
                    //We found an optimum --> end freq optimization algorithm
                    freq_opt <= 1;
                    //assign freq_ready = 1;
                end
                //No optimum
                else begin
                    freq_set_up_down <= ~freq_set_up_down;
                    freq_ready <= 1;
                end
            end

            else begin
                //Optimum
                //We found an optimum --> end freq optimization algorithm
				freq_set_up_down <= freq_set_up_down;
                freq_opt <= 1;
                freq_ready <= 0;
            end
        end

        else begin
            //Compare the new current value to the existing highest one
            //new_highest is always a value between 0 and 7FF = 11bit
			freq_ready <= 0;
			freq_opt <= 0;
			freq_set_up_down <= freq_set_up_down;
            if(ADC_in < 12'h800 && ADC_in > new_highest)begin
                new_highest <= ADC_in; //ADC_in is value between 0 and 7FF and is larger than new_highest
            end
            else if((ADC_in > 12'h800 || ADC_in == 12'h800) && 12'hFFF - ADC_in > new_highest)begin
                new_highest <= 12'hFFF - ADC_in;
            end
			else
            	clk_cycles <= clk_cycles - 1;
        end
    end

	assign freq_rdy = freq_ready;
	//assign freq_set_up_dwn = freq_set_up_down;
	//assign freq_optimum = freq_opt;

endmodule
