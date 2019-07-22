//TODO: Change the counter duration for Morse Input
//Connect everything
module MorseBuddy(CLOCK_50, KEY, SW, LEDR);
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	wire reset, clk, keyIn, startSubCont;
	wire[5:0] seed;
	assign seed = SW[5:0]; //note: seed currently does nothing
	assign clk = CLOCK_50;
	assign reset = KEY[0];
	assign keyIn = KEY[1];
	assign startSubCont = KEY[3];
	// wire keyPressed;
	// wire [7:0] keyCode;
	// keyboard_handler keyboard0(clk, reset, PS2_CLK, PS2_DAT,keyPressed, keyCode);

	wire [5:0] letterCode, fixedLetterCode;
	wire pollLetter, morseEn, letterDisp, checkAnswer, validationDone, correct;
	wire resetDatapath;

	datapath data0(clk, resetDatapath, keyIn, letterCode, pollLetter, morseEn, letterDisp, checkAnswer, validationDone, correct, fixedLetterCode);
	control c0(clk, reset, seed, startSubCont, startSubCont, validationDone, correct, startSubCont, pollLetter, morseEn, letterDisp, letterCode, checkAnswer, resetDatapath);
	assign LEDR = {correct, 3'b000, fixedLetterCode};
endmodule

module displayLetter(clk, reset, displayEn, letterCode);
	input clk, reset, displayEn;
	input[5:0] letterCode;
	//TODO: Connect this
endmodule

module datapath(clk, reset, keyIn, letterCode, pollLetter, morseEn, letterDisp, checkAnswer, validationDone, correct, fixedLetterCode);
	input clk, reset, keyIn, pollLetter, morseEn, letterDisp, checkAnswer;
	input[5:0] letterCode;
	output reg validationDone, correct;
	wire [9:0] morseIn;
	output reg[5:0] fixedLetterCode;
	wire [7:0] scanCode;

	wire[9:0] validMorse;
	encodingToScanLUT es0(fixedLetterCode, scanCode);
	scanToMorseLUT sm0(scanCode, validMorse);

	inputHandler i0(clk, reset, keyIn, morseEn, morseIn);
	displayLetter d0(clk, reset, letterDisp, fixedLetterCode);
	always @(posedge clk) begin
		if(!reset) begin
			fixedLetterCode <= 6'd0; //NOTE: invalid code
			validationDone <= 1'b0;
			correct <= 1'b0;
		end
		else begin
			if (pollLetter) fixedLetterCode <= letterCode; 
			if (checkAnswer) begin
				if (validMorse == morseIn) correct <= 1'b1;
				else correct <= 1'b0;
				validationDone <= 1'b1;
			end
		end
	end
endmodule


module control(
	clk, reset, seed, start, submit, validationDone, correct, continue, 
	pollLetter, enableMorse, displayLetter, letterCode, checkAnswer, resetDatapath
	);
	input clk, reset, start, submit, validationDone, correct, continue;
	input[5:0] seed;
	output reg pollLetter, enableMorse, displayLetter, checkAnswer, resetDatapath;
	output [5:0] letterCode;
	localparam 
		START = 4'd0,
		START_WAIT = 4'd1,
		RESET = 4'd2,
		GENERATE_LETTER = 4'd3,
		DISPLAY_LETTER = 4'd4,
		MORSE_INPUT = 4'd5,
		MORSE_WAIT = 4'd6,
		SUBMIT = 4'd7,
		END = 4'd8;

	reg[3:0] current_state, next_state;

	wire validLetter;
	generateRandomLetter r0(clk, reset, seed, letterCode, validLetter); 
	always @(*) begin
		case(current_state)
			START: next_state <= start ? START: START_WAIT;
			START_WAIT: next_state <= start ? RESET: START_WAIT;
			RESET: next_state <= GENERATE_LETTER;
			GENERATE_LETTER: next_state <= validLetter ? DISPLAY_LETTER : GENERATE_LETTER;
			DISPLAY_LETTER: next_state <= MORSE_INPUT;
			MORSE_INPUT: next_state <= submit ? MORSE_INPUT: MORSE_WAIT;
			MORSE_WAIT: next_state <= submit ? SUBMIT : MORSE_WAIT;
			// SUBMIT: next_state <= validationDone ? (correct ? CORRECT: INCORRECT) : SUBMIT;
			SUBMIT: next_state <= validationDone ? END : SUBMIT;
			END: next_state <= continue ? END : START;
		endcase
	end

	always @(*) begin
		pollLetter <= 1'b0;
		enableMorse <= 1'b0;
		displayLetter <= 1'b0;
		checkAnswer <= 1'b0;
		resetDatapath <= 1'b1;
		case(current_state)
			START: resetDatapath <= 1'b0;
			START_WAIT: resetDatapath <= 1'b0;
			GENERATE_LETTER: pollLetter <= 1'b1;
			DISPLAY_LETTER: displayLetter <= 1'b1;
			MORSE_INPUT: enableMorse <= 1'b1;
			SUBMIT: begin
				checkAnswer <= 1'b1;
				enableMorse <= 1'b1;
			end
		endcase
	end
	
	always @(posedge clk) begin
		$display("State: %4b", next_state);
		if (!reset) begin
			current_state <= START;
		end
		else begin
			current_state <= next_state;
		end
	end
endmodule


module inputHandler(clk, reset, keyIn, enable, curCode);
	input clk, reset, keyIn, enable;
	output reg[9:0] curCode; //5 2-bit seminibbles (10 = dot, 11 = dash)
	reg[2:0] semiNibblesUsed;
	wire dot, dash;
	reg[3:0] position;

	MorseInput m0 (clk, reset, keyIn, dot, dash);
	always @(*) begin
		position <= 4'd9 - semiNibblesUsed * 2;
	end

	always @(posedge clk) begin
		// $display("Enable: %b", enable);
		// $display("Dash: %b", dash);
		if (!reset) begin
			semiNibblesUsed <= 3'd0;
			curCode    <= 10'd0;
		end
		else if(enable) begin
			if (dot) begin
				if(semiNibblesUsed < 3'd5) begin
					curCode[position] <= 1'b1;
					curCode[position-1'b1] <= 1'b0;
					semiNibblesUsed <= semiNibblesUsed + 1'b1;
				end
				else begin //need to overwrite values
					curCode = curCode << 2;
					curCode[1:0] <= 2'b10;
				end
			end
			else if (dash) begin
				if(semiNibblesUsed < 3'd5) begin
					curCode[position] <= 1'b1;
					curCode[position-1'b1] <= 1'b1;
					semiNibblesUsed <= semiNibblesUsed + 1'b1;
				end
				else begin //need to overwrite values
					curCode = curCode << 2;
					curCode[1:0] <= 2'b11;
				end
			end
		end
	end
endmodule

// this really does not work at the moment
module LFSR(clk, reset, seed, out); //6-bit Fibonacci LFSR
	input clk, reset;
	input[5:0] seed;
	output reg[5:0] out;
	reg[5:0] bit;

	//Feedback polynomial: x^6 + x^5 + 1 (from wikipedia)
	always @(posedge clk) begin
		if (!reset) begin
			out <= seed;
			bit <= 6'd0;
		end
		else begin
			bit <= (out >> 0) ^ (out >> 1);
			out <= (out >> 1) | (bit << 3);
			if(out == 6'd0) begin //0 will lock the LFSR
				out <= seed;
			end
		end
	end
endmodule

//the randomness comes from when it's polled
module pseudoRandomCounter(clk, reset, letterCode); 
	input clk, reset;
	output reg[5:0] letterCode;
	always @(posedge clk) begin
		if (!reset) begin
			letterCode <= 6'd1;
		end
		else if (letterCode + 1'b1 < 6'd37) letterCode <= letterCode + 1'b1;
		else letterCode <= 6'd1;
	end
endmodule

module generateRandomLetter(clk, reset, seed, letterCode, valid);
	input clk, reset;
	input [5:0] seed;
	output[5:0] letterCode;
	output valid;
	// LFSR lfsr0(clk, reset, seed, letterCode);
	pseudoRandomCounter prc1(clk, reset, letterCode);
	assign valid = (letterCode < 6'd37 & letterCode > 6'd0);
endmodule

module encodingToScanLUT(letterCode, scanCode);
	input[5:0] letterCode;
	output reg [7:0] scanCode;
	always @(*) begin
		case(letterCode)
			6'd1: scanCode <= 8'h45; //0
			6'd2: scanCode <= 8'h16; //1
			6'd3: scanCode <= 8'h1E; //2
			6'd4: scanCode <= 8'h26; //3
			6'd5: scanCode <= 8'h25; //4
			6'd6: scanCode <= 8'h2E; //5
			6'd7: scanCode <= 8'h36; //6
			6'd8: scanCode <= 8'h3D; //7
			6'd9: scanCode <= 8'h3E; //8
			6'd10: scanCode <= 8'h46; //9
			6'd11: scanCode <= 8'h1C; //a
			6'd12: scanCode <= 8'h32; //b
			6'd13: scanCode <= 8'h21; //c
			6'd14: scanCode <= 8'h23; //d
			6'd15: scanCode <= 8'h24; //e
			6'd16: scanCode <= 8'h2B; //f
			6'd17: scanCode <= 8'h34; //g
			6'd18: scanCode <= 8'h33; //h
			6'd19: scanCode <= 8'h43; //i
			6'd20: scanCode <= 8'h3B; //j
			6'd21: scanCode <= 8'h42; //k
			6'd22: scanCode <= 8'h4B; //l
			6'd23: scanCode <= 8'h3A; //m
			6'd24: scanCode <= 8'h31; //n
			6'd25: scanCode <= 8'h44; //o
			6'd26: scanCode <= 8'h4D; //p
			6'd27: scanCode <= 8'h15; //q
			6'd28: scanCode <= 8'h2D; //r
			6'd29: scanCode <= 8'h1B; //s
			6'd30: scanCode <= 8'h2C; //t
			6'd31: scanCode <= 8'h3C; //u
			6'd32: scanCode <= 8'h2A; //v
			6'd33: scanCode <= 8'h1D; //w
			6'd34: scanCode <= 8'h22; //x
			6'd35: scanCode <= 8'h35; //y
			6'd36: scanCode <= 8'h1A; //z
			default: scanCode <= 8'd0;
		endcase
	end	
endmodule

module scanToMorseLUT(scanCode, morseEncoding);
	input[7:0] scanCode;
	output reg [9:0] morseEncoding;
	always @(*) begin
		case(scanCode)
			8'h45:	morseEncoding <= 10'b1111111111; //0
			8'h16:	morseEncoding <= 10'b1011111111; //1
			8'h1E:	morseEncoding <= 10'b1010111111; //2
			8'h26:	morseEncoding <= 10'b1010101111; //3
			8'h25:	morseEncoding <= 10'b1010101011; //4
			8'h2E:	morseEncoding <= 10'b1010101010; //5
			8'h36:	morseEncoding <= 10'b1111010100; //6
			8'h3D:	morseEncoding <= 10'b1111110100; //7
			8'h3E:	morseEncoding <= 10'b1111111100; //8
			8'h46:	morseEncoding <= 10'b1111111110; //9
			8'h1C:	morseEncoding <= 10'b1011000000; //a
			8'h32:	morseEncoding <= 10'b1110101000; //b
			8'h21:	morseEncoding <= 10'b1110111000; //c
			8'h23:	morseEncoding <= 10'b1110100000; //d
			8'h24:	morseEncoding <= 10'b1000000000; //e
			8'h2B:	morseEncoding <= 10'b1010111000; //f
			8'h34:	morseEncoding <= 10'b1111100000; //g
			8'h33:	morseEncoding <= 10'b1010101000; //h
			8'h43:	morseEncoding <= 10'b1010000000; //i
			8'h3B:	morseEncoding <= 10'b1011111100; //j
			8'h42:	morseEncoding <= 10'b1110110000; //k
			8'h4B:	morseEncoding <= 10'b1011101000; //l
			8'h3A:	morseEncoding <= 10'b1111000000; //m
			8'h31:	morseEncoding <= 10'b1110000000; //n
			8'h44:	morseEncoding <= 10'b1111110000; //o
			8'h4D:	morseEncoding <= 10'b1011111000; //p
			8'h15:	morseEncoding <= 10'b1111101100; //q
			8'h2D:	morseEncoding <= 10'b1011100000; //r
			8'h1B:	morseEncoding <= 10'b1010100000; //s
			8'h2C:	morseEncoding <= 10'b1100000000; //t
			8'h3C:	morseEncoding <= 10'b1010110000; //u
			8'h2A:	morseEncoding <= 10'b1010101100; //v
			8'h1D:	morseEncoding <= 10'b1011110000; //w
			8'h22:	morseEncoding <= 10'b1110101100; //x
			8'h35:	morseEncoding <= 10'b1110111100; //y
			8'h1A:	morseEncoding <= 10'b1111101000; //z

			default: morseEncoding <= 15'd0;
		endcase
	end
endmodule

module MorseInput(clk,reset, keyIn, dot, dash);
	input clk, reset, keyIn;

	output reg dot, dash;
	localparam S_WAIT = 2'd0,
			   S_KEYDOWN = 2'd1,
			   S_KEYUP = 2'd2,
			   S_RESET = 2'd3;


	reg[1:0] current_state, next_state;

	always @(*)
		begin
			case(current_state)
				S_WAIT : next_state = keyIn ? S_WAIT : S_KEYDOWN;
				S_KEYDOWN : next_state = keyIn ? S_KEYUP: S_KEYDOWN;
				S_KEYUP :next_state = S_RESET;
				S_RESET : next_state = S_WAIT;
				default : next_state = S_WAIT;
			endcase // current_state
		end


	wire enableDash;
	reg resetInputCounter;
	inputCounter iC0(clk, resetInputCounter, enableDash);
	always @(*)
		begin
			dot  <= 1'b0;
			dash <= 1'b0;
			resetInputCounter <= 1'b0;
			case(current_state)
				S_KEYDOWN : resetInputCounter <= 1'b1;
				S_KEYUP :
					begin
						// $display("%b", enableDash);
						if(enableDash) dash <= 1'b1;
						else dot <= 1'b1;
					end
			endcase
		end

    always @(posedge clk)
    begin
    	// $display("%2b",next_state);
    	if(!reset) current_state = S_WAIT;
    	else current_state = next_state;
    end
endmodule

module inputCounter(clk, reset, enableDash);
	input clk, reset;
	output enableDash;
	reg[25:0] q;
	always @(posedge clk)
	begin
		if(!reset) q <= 0;
		else begin
			if(q + 1 == 0) begin //overflow
				// q <= 25'b1011111010111100001000000;
				q <= 25'd10;
			end
			q <= q + 1;

		end
	end
	// assign enableDash = q >= 25'b1011111010111100001000000 ? 1 : 0;
	assign enableDash = q >= 25'd10;
endmodule

//modified from sample code
module keyboard_handler (
	input  clk,
	input  reset,
	inout  PS2_CLK,
	inout  PS2_DAT,
	output keyPressed,
	output reg [7:0] keyCode
);

	// A flag indicating when the keyboard has sent a new byte.
	wire byte_received;
	// The most recent byte received from the keyboard.
	wire [7:0] newest_byte;

	localparam // States indicating the type of code the controller expects
		// to receive next.
		MAKE            = 2'b00,
		BREAK           = 2'b01,
		SECONDARY_MAKE  = 2'b10,
		SECONDARY_BREAK = 2'b11;

	reg [1:0] curr_state;

	reg key_press;

	reg key_lock;

	// Output is equal to the key press wires in mode 0 (hold), and is similar in
	// mode 1 (pulse) except the signal is lowered when the key's lock goes high.
	// TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
	assign keyPressed = key_press && ~key_lock;

	PS2_Controller #(.INITIALIZE_MOUSE(0)) core_driver (
		.CLOCK_50        (clk),
		.reset           (~reset       ),
		.PS2_CLK         (PS2_CLK      ),
		.PS2_DAT         (PS2_DAT      ),
		.received_data   (newest_byte  ),
		.received_data_en(byte_received)
	);

	always @(posedge clk) begin
		curr_state <= MAKE;
		key_lock <= key_press;
		if (~reset) begin
			curr_state <= MAKE;
			key_press <= 1'b0;
			key_lock <= 1'b0;
		end
		else if (byte_received) begin
			case (newest_byte)
				8'he0 : curr_state <= SECONDARY_MAKE;
				8'hf0 : curr_state <= curr_state == MAKE ? BREAK : SECONDARY_BREAK;
				default: begin
					key_press <= curr_state == MAKE;
					keyCode <= newest_byte;
				end 
			endcase
		end
		else begin
			curr_state <= curr_state;
		end
	end
	assign keyPressed = key_press;
endmodule