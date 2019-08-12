
//TODO: Change the counter duration for Morse Input
//Connect everything
module MorseBuddy(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
									VGA_CLK,                         //  VGA Clock
									VGA_HS,                         //  VGA H_SYNC
									VGA_VS,                         //  VGA V_SYNC
									VGA_BLANK_N,                    //  VGA BLANK
									VGA_SYNC_N,                     //  VGA SYNC
									VGA_R,                          //  VGA Red[9:0]
									VGA_G,                          //  VGA Green[9:0]
									VGA_B,                          //  VGA Blue[9:0]
									PS2_CLK,
									PS2_DAT
);
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	wire reset, clk, keyIn1, proceed, mode;
	wire[5:0] seed;
	assign seed = SW[5:0];
	assign clk = CLOCK_50;
	assign reset = SW[8];
	assign keyIn1 = KEY[0];
	assign proceed1 = KEY[1];
	assign proceed2 = KEY[2];
	assign keyIn2 = KEY[3];
	assign mode = SW[9]; // 0 = text --> morse, 1 = morse --> text
	output[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output      VGA_CLK;    //  VGA Clock
	output      VGA_HS;     //  VGA H_SYNC
	output      VGA_VS;     //  VGA V_SYNC
	output      VGA_BLANK_N; // VGA BLANK
	output      VGA_SYNC_N;  // VGA SYNC
	output [9:0] VGA_R;     //  VGA Red[9:0]
	output [9:0] VGA_G;     //  VGA Green[9:0]
	output [9:0] VGA_B;     //  VGA Blue[9:0]
	inout PS2_CLK,PS2_DAT;
	wire[2:0] colour;
	wire[7:0] x;
	wire[6:0] y;
	wire vgaEn, player1Win, player2Win;
	wire[9:0] morseIn1, curLetterCode1, morseIn2, curLetterCode2;
	wire[1:0] correct;
	gameManager gameManager0(clk, reset, seed, keyIn1, keyIn2, proceed1, proceed2, mode, x, y, colour, vgaEn, morseIn1, curLetterCode1, morseIn2, curLetterCode2, correct, player1Win, player2Win);
	assign LEDR= {player1Win, player2Win, 6'd0, correct};
	hex_decoder hex0(morseIn1[3:0], HEX0);
	hex_decoder hex1(morseIn1[7:4], HEX1);
	hex_decoder hex2({2'b00,morseIn1[9:8]}, HEX2);
	hex_decoder hex3(morseIn2[3:0], HEX3);
	hex_decoder hex4(morseIn2[7:4], HEX4);
	hex_decoder hex5({2'b00,morseIn2[9:8]}, HEX5);

	//  vga_adapter VGA(
	//         .resetn(reset),
	//         .clock(CLOCK_50),
	//         .colour(colour),
	//         .x(x),
	//         .y(y),
	//         .plot(vgaEn),
	//         /* Signals for the DAC to drive the monitor. */
	//         .VGA_R(VGA_R),
	//         .VGA_G(VGA_G),
	//         .VGA_B(VGA_B),
	//         .VGA_HS(VGA_HS),
	//         .VGA_VS(VGA_VS),
	//         .VGA_BLANK(VGA_BLANK_N),
	//         .VGA_SYNC(VGA_SYNC_N),
	//         .VGA_CLK(VGA_CLK));
	//     defparam VGA.RESOLUTION = "160x120";
	//     defparam VGA.MONOCHROME = "FALSE";
	//     defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	// defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule

module gameManager(clk, reset, seed, keyIn1, keyIn2, proceed1, proceed2, mode, x, y, colour, vgaEn, morseIn1, curLetterCode1, morseIn2, curLetterCode2, correct, player1Win, player2Win);
	input clk, reset, keyIn1, keyIn2, proceed1, proceed2, mode;
	input[5:0] seed;
	output vgaEn, player1Win, player2Win;
	output reg[7:0] x;
	output reg[6:0] y;
	output reg[2:0] colour;
	output[9:0] morseIn1, curLetterCode1, morseIn2, curLetterCode2;
	reg doneGeneratingLetters;
	wire[1:0] keyIn, proceed, finishedAllVerification, doneDrawIndividual, doneDrawAll;
	output[1:0] correct;
	assign proceed = {proceed2, proceed1};
	assign keyIn = {keyIn2, keyIn1};
	wire generateLetters, resetDatapath, wipeScreen;
	wire[1:0] enableInput, displayMatch, resetInput, verify, resetMod, resetDisplayIndividual, drawInputEn;
	
	reg[49:0] morseCodes;
	reg[29:0] letterCodes;
	reg[2:0] lettersToGenerate;
	wire valid;
	wire[5:0] letterCode;
	wire [7:0] scanCode;
	wire [9:0] morseCode;
	generateRandomLetter genRandLetter0(clk, reset, seed, letterCode, valid);
	encodingToScanLUT enToScan0(letterCode, scanCode);
	scanToMorseLUT scToMo0(scanCode, morseCode);

	wire[7:0] x1, x2;
	wire[6:0] y1, y2;
	wire[2:0] colour1, colour2;

	wire[1:0] datapath_clk;
	clock_offsetter clockOffset0(clk, reset, datapath_clk[0], datapath_clk[1]);
	reg curMode;
	datapath player1(
		datapath_clk[0],
		resetDatapath,
		morseCodes,
		letterCodes,
		displayMatch[0],
		resetDisplayIndividual[0],
		enableInput[0],
		resetInput[0],
		resetMod[0],
		keyIn[0],
		verify[0],
		mode,
		7'd10,

		ps2Clk,
		ps2Dat,

		finishedAllVerification[0],
		correct[0],
		x1,
		y1,
		colour1,
		morseIn1,
		curLetterCode1,
		doneDrawIndividual[0],
		doneDrawAll[0],
		drawInputEn[0]
		);
	datapath player2(
		datapath_clk[1],
		resetDatapath & ~curMode,
		morseCodes,
		letterCodes,
		displayMatch[1],
		resetDisplayIndividual[1],
		enableInput[1],
		resetInput[1],
		resetMod[1],
		keyIn[1],
		verify[1],
		mode,
		7'd70,

		ps2Clk,
		ps2Dat,

		finishedAllVerification[1],
		correct[1],
		x2,
		y2,
		colour2,
		morseIn2,
		curLetterCode2,
		doneDrawIndividual[1],
		doneDrawAll[1],
		drawInputEn[1]
		);
	wire [2:0] current_state;
	control control0(
		clk,
		datapath_clk[0],
		datapath_clk[1],
		reset, 
		proceed, 
		doneGeneratingLetters,
		finishedAllVerification,
		correct,
		doneDrawIndividual,
		doneDrawAll,

		generateLetters,
		wipeScreen,
		resetDatapath,
		enableInput,
		displayMatch,
		resetInput,
		verify,
		resetMod,
		resetDisplayIndividual,
		current_state,
		player1Win,
		player2Win
	 ); 
	always @(posedge clk) begin
		if(~reset) begin
			morseCodes            <= 50'd0;
			letterCodes           <= 30'd0;
			lettersToGenerate     <= 3'd4;
			doneGeneratingLetters <= 1'b0;
			curMode <= mode;
		end
		else begin
			if(generateLetters) begin
				if(valid) begin
					morseCodes  <= morseCodes | (morseCode << 10 * lettersToGenerate);
					letterCodes <= letterCodes | (letterCode << 6* lettersToGenerate);
					if(lettersToGenerate == 1'b0) begin
						doneGeneratingLetters <= 1'b1;
					end
					else begin
						lettersToGenerate <= lettersToGenerate - 1'b1;
					end
				end
			end
		end
	end
	wire[7:0] wipeX;
	wire[6:0] wipeY;
	wire[2:0] wipeColour;
	wipeScreen wS0(clk,wipeScreen&reset,wipeX,wipeY,wipeColour);

	reg vgaDatapathEn;
	always @(posedge clk) begin
		if (~reset) begin
			x <= 8'd0;
			y <= 7'd0;
			colour <= 3'b000;
			vgaDatapathEn <= 1'b0;
		end
		else if(~wipeScreen) begin
			if(datapath_clk[0]) begin
				x <= x1;
				y <= y1;
				colour <= colour1;
				vgaDatapathEn <= displayMatch[0] | drawInputEn[0];
			end
			else begin //datapath_clk[1]
				x <= x2;
				y <= y2;
				colour <= colour2;
				vgaDatapathEn <= displayMatch[1] | drawInputEn[1];
			end
		end
		else begin
			x      <= wipeX;
			y      <= wipeY;
			colour <= wipeColour;
		end
	end
	assign vgaEn = vgaDatapathEn | wipeScreen;
endmodule

module clock_offsetter(clk, reset, clk1, clk2);
	input clk, reset;
	output clk1, clk2;
	reg counter1, counter2;
	always @(posedge clk) begin
		if (~reset) begin
			counter1 <= 1'b0;
			counter2 <= 1'b1;
		end
		else begin
			counter1 <= counter1 + 1'b1;
			counter2 <= counter2 + 1'b1;
		end
	end
	assign clk1 = counter1 == 1'b0;
	assign clk2 = counter2 == 1'b0;
endmodule

module datapath(
	clk,reset, morseCodes, letterCodes, displayMatch, resetDrawIndividual, enableInput, resetInput, 
	resetMod, keyIn, verify, mode, topY,
	 ps2Clk, ps2Dat, 
	finishedAllVerification, correct, x, y, colour, morseIn,
	curLetterCode, doneDrawIndividual, doneDrawAll, drawInputEn
);
	parameter numLetters = 5;
	parameter numLetterBits = numLetters * 10;
	parameter numLetterBits2 = numLetters * 6;
	input clk, reset, displayMatch, resetDrawIndividual, enableInput, resetInput, resetMod, verify, keyIn, mode;
	input [6:0] topY;
	input [49:0] morseCodes;
	input [29:0] letterCodes;
	inout ps2Dat, ps2Clk;
	output reg finishedAllVerification, correct, doneDrawAll, doneDrawIndividual, drawInputEn;
	output reg[7:0] x;
	output reg[6:0] y;
	output reg[2:0] colour;
	output [9:0] morseIn;
	output [9:0] curLetterCode;
	
	reg [3:0] lettersDone;

	wire[7:0] letterX, morseX, keyMorseX, keyLetterX;
	wire[6:0] letterY, morseY, keyMorseY, keyLetterY;
	wire[2:0] letterColour, morseColour, keyMorseColour, keyLetterColour;

	reg curMode;

	wire [3:0] morseLettersDone;
	wire morseCorrect, morseFinishedAll, morseDoneInd, morseDoneAll, morseDrawEn;
	wire [3:0]keyLettersDone;
	wire keyPressed, keyCorrect, keyFinishedAll, keyDoneInd, keyDoneAll, keyDrawEn;

	morseMatch morMatch0(clk, reset & resetMod, morseCodes, keyIn, enableInput, resetInput, verify,
											 morseCorrect, morseFinishedAll, morseIn, morseLettersDone, topY, morseX, morseY, morseColour, morseDrawEn);

	displayAllLetters displayLetter0(clk, displayMatch, resetDrawIndividual, letterCodes, morseLettersDone, topY, letterX, letterY, letterColour, morseDoneInd, morseDoneAll);

	keyboardMatch keyMatch0 (
		clk, reset & resetMod, morseCodes, verify, topY, ps2Clk, ps2Dat,
		keyPressed, keyCorrect, keyLettersDone, keyFinishedAll, keyLetterX, keyLetterY, keyLetterColour, keyDrawEn
	);
	displayAllMorse dispMorseAll0 (clk,displayMatch,resetDrawIndividual,morseCodes,keyLettersDone,topY, keyMorseX,keyMorseY,keyMorseColour,keyDoneInd,keyDoneAll);
	reg[numLetterBits-1:0] shiftedMorseCodes;
	assign curLetterCode = shiftedMorseCodes[numLetterBits-1:numLetterBits-10];
	wire done;
	
	always @(posedge clk) begin
		if (~reset) begin
			curMode <= mode;
		end
		else begin
			shiftedMorseCodes = (morseCodes << 10 * lettersDone);
		end
	end
	always @(posedge clk) begin
		if(~reset) begin
			x                       <= 0;
			y                       <= 0;
			colour                  <= 0;
			correct                 <= 0;
			finishedAllVerification <= 0;
			lettersDone             <= 0;
			drawInputEn             <= 0;
			doneDrawAll             <= 0;
			doneDrawIndividual      <= 0;
		end
		else begin
			if(~curMode) begin
				correct                 <= morseCorrect;
				finishedAllVerification <= morseFinishedAll;
				lettersDone             <= morseLettersDone;
				drawInputEn             <= morseDrawEn;
				doneDrawIndividual      <= morseDoneInd;
				doneDrawAll             <= morseDoneAll;
				if(displayMatch) begin
					x      <= letterX;
					y      <= letterY;
					colour <= letterColour;
				end
				else if(morseDrawEn) begin
					x      <= morseX;
					y      <= morseY;
					colour <= morseColour;
				end
				else begin
					x      <= 0;
					y      <= 0;
					colour <= 0;
				end
			end
			else begin
				correct                 <= keyCorrect;
				finishedAllVerification <= keyFinishedAll;
				lettersDone             <= keyLettersDone;
				drawInputEn             <= keyDrawEn;
				doneDrawIndividual      <= keyDoneInd;
				doneDrawAll             <= keyDoneAll;
				if(displayMatch) begin
					x      <= keyMorseX;
					y      <= keyMorseY;
					colour <= keyMorseColour;
				end
				else if(keyDrawEn) begin
					x      <= keyLetterX;
					y      <= keyLetterY;
					colour <= keyLetterColour;
				end
				else begin
					x      <= 0;
					y      <= 0;
					colour <= 0;
				end
			end
		end
	end
endmodule

module wipeScreen(clk, reset, x, y, colour);
	input clk, reset;
	output reg[7:0] x;
	output reg[6:0] y;
	output[2:0] colour;
	always @(posedge clk) begin
		if(~reset) begin
			x <= 8'd0;
			y <= 7'd0;
		end
		else begin
			if (x + 1'b1 >= 8'd160) begin
				y <= y + 1'b1;
				x <= 8'd0;
			end
			else begin
				x <= x + 1'b1;
			end
		end
	end
	assign colour = 3'b000;
endmodule

module keyboardMatch(clk, reset, morseCodes, verify, topY, PS2_CLK, PS2_DAT, keyPressed, correct, lettersDone, finishedAllVerification, x, y, colour, drawEn);
	parameter numLetters = 5;
	parameter numLetterBits = numLetters * 10;
	input clk, reset, verify;
	input [numLetterBits-1:0] morseCodes;
	input[6:0] topY;
	reg [numLetterBits-1:0] curMorse;
	inout PS2_CLK, PS2_DAT;
	output correct, finishedAllVerification;
	output keyPressed; //This is a pulse signal
	output[7:0] x;
	output[6:0] y;
	output[2:0] colour;
	output reg drawEn;
	wire[7:0] keyCode;
	keyboard_handler keyboard0(clk, reset, PS2_CLK, PS2_DAT, keyPressed, keyCode);
	wire [5:0] letterCode;
	wire [14:0] curPattern;
	scanToEncodingLUT scanToLetLUT(keyCode, letterCode);
	patternEncoding pattern0(letterCode, curPattern);
	assign finishedAllVerification = curMorse == {numLetterBits{1'b0}};
	wire done;
	displayLetter displayLet1(clk, reset & drawEn & ~done, curPattern, 8'd20, topY+7'd20, 3'b111, x, y, colour, done);
	wire[9:0] morseIn;
	scanToMorseLUT keyboardMatchLUT(keyCode, morseIn);
	wire correct;
	output reg [3:0] lettersDone;
	assign correct = curMorse[numLetterBits-1:numLetterBits-10] == morseIn;
	always @(posedge keyPressed) begin
		drawEn <= 1'b1;
	end

	always @(posedge clk) begin
		if (~reset) begin
			curMorse <= morseCodes;
			lettersDone <= 4'b0;
		end
		else begin
			if (verify & correct) begin
				curMorse <= curMorse << 10;
				lettersDone <= lettersDone + 1'b1;
			end

		end
	end

endmodule

module morseMatch(clk, reset, morseCodes, keyIn, enableInput, resetInput, verify,correct, finishedAllVerification, morseIn, lettersDone, topY, x, y, colour, drawEn);
	parameter numLetters = 5;
	parameter numLetterBits = numLetters * 10;
	input clk, reset, keyIn, enableInput, resetInput, verify;
	input [numLetterBits-1:0] morseCodes;
	input[6:0] topY;
	output correct, finishedAllVerification, drawEn;
	output reg[3:0] lettersDone;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	reg[numLetterBits-1:0] curMorse;
	output[9:0] morseIn;
	assign finishedAllVerification = curMorse == {numLetterBits{1'b0}};
	inputHandler morseIn0(clk, resetInput & reset, keyIn, enableInput, topY, morseIn, x, y, colour, drawEn);
	assign correct = curMorse[numLetterBits-1:numLetterBits-10] == morseIn;
	always @(posedge clk) begin
		if (~reset) begin
			curMorse <= morseCodes;
			lettersDone <= 4'd0;
		end
		else if(verify & correct) begin
			$display("Correct");
			$display("%0b", curMorse);
			$display("%4b", lettersDone);
			curMorse <= curMorse << 10;
			lettersDone <= lettersDone + 1'b1;
		end
		else if(verify) begin
			$display("Incorrect");
			$display("%10b", morseIn);
			$display("%10b", curMorse[numLetterBits-1:numLetterBits-10]);
		end
	end
endmodule

module control(
	clk, clk1, clk2, reset, proceed, doneGeneratingLetters, finishedAllVerification,
	correct, doneDrawIndividual, doneDrawAll,
	generateLetters, wipeScreen,  resetDatapath,enableInput, displayMatch, resetInput, verify,
	resetMod, resetDisplayIndividual, current_state, player1Win, player2Win
);
	input clk, clk1, clk2, reset, doneGeneratingLetters;
	input[1:0] proceed, finishedAllVerification, correct, doneDrawIndividual, doneDrawAll;
	output reg generateLetters, wipeScreen, resetDatapath, player1Win, player2Win;
	output reg[1:0] enableInput, displayMatch, resetInput, verify, resetMod,  resetDisplayIndividual;

	localparam
		START = 3'd0,
		START_WAIT = 3'd1,
		GENERATE_LETTERS = 3'd2,
		GAMEPLAY = 3'd3,
		PLAYER1_WIN = 3'd4,
		PLAYER2_WIN = 3'd5,
		FINISH_WAIT = 3'd6;

	localparam
		RESET_DISPLAY_MATCH = 3'd0,
		RESET_DISPLAY_INDIVIDUAL = 3'd1,
		DISPLAY_MATCH = 3'd2,
		RESET_INPUT_MODULE = 3'd3,
		RESET_INPUT = 3'd4,
		INPUT = 3'd5,
		VERIFY_WAIT = 3'd6,
		VERIFY = 3'd7;

	output reg[2:0] current_state; //output for debugging purposes
	reg[2:0] next_state;

	reg[2:0] player1_state;
	reg[2:0] player1_next;

	reg[2:0] player2_state;
	reg[2:0] player2_next;

	always @(*) begin
		case(current_state)
			START : begin
				next_state   <= &proceed ? START: START_WAIT;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			START_WAIT : begin
				next_state   <= &proceed ? GENERATE_LETTERS: START_WAIT;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			GENERATE_LETTERS : begin
				next_state   <= doneGeneratingLetters ? GAMEPLAY : GENERATE_LETTERS;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			GAMEPLAY : begin
				if(|finishedAllVerification) next_state <= finishedAllVerification[0] ? PLAYER1_WIN:PLAYER2_WIN;
				else next_state <= GAMEPLAY;
				case(player1_state)
					RESET_DISPLAY_MATCH      : player1_next <= RESET_DISPLAY_INDIVIDUAL;
					RESET_DISPLAY_INDIVIDUAL : player1_next <= DISPLAY_MATCH;
					DISPLAY_MATCH            : player1_next <= doneDrawIndividual[0] ? (doneDrawAll[0]? RESET_INPUT_MODULE:RESET_DISPLAY_INDIVIDUAL): DISPLAY_MATCH;
					RESET_INPUT_MODULE       : player1_next <= RESET_INPUT;
					RESET_INPUT              : player1_next <= INPUT;
					INPUT                    : player1_next <= proceed[0] ? INPUT : VERIFY_WAIT;
					VERIFY_WAIT              : player1_next <= proceed[0] ? VERIFY: VERIFY_WAIT;
					VERIFY                   : player1_next <= correct[0] ? RESET_DISPLAY_MATCH : RESET_INPUT;
				endcase
				case(player2_state)
					RESET_DISPLAY_MATCH      : player2_next <= RESET_DISPLAY_INDIVIDUAL;
					RESET_DISPLAY_INDIVIDUAL : player2_next <= DISPLAY_MATCH;
					DISPLAY_MATCH            : player2_next <= doneDrawIndividual[1] ? (doneDrawAll[1]? RESET_INPUT_MODULE:RESET_DISPLAY_INDIVIDUAL): DISPLAY_MATCH;
					RESET_INPUT_MODULE       : player2_next <= RESET_INPUT;
					RESET_INPUT              : player2_next <= INPUT;
					INPUT                    : player2_next <= proceed[1] ? INPUT : VERIFY_WAIT;
					VERIFY_WAIT              : player2_next <= proceed[1] ? VERIFY: VERIFY_WAIT;
					VERIFY                   : player2_next <= correct[1] ? RESET_DISPLAY_MATCH : RESET_INPUT;
				endcase

			end
			PLAYER1_WIN : begin
				next_state   <= &proceed ? PLAYER1_WIN : FINISH_WAIT;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			PLAYER2_WIN : begin
				next_state   <= &proceed ? PLAYER2_WIN : FINISH_WAIT;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			FINISH_WAIT : begin
				next_state   <= &proceed ? START : FINISH_WAIT;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
			default : begin
				next_state   <= START;
				player1_next <= RESET_DISPLAY_MATCH;
				player2_next <= RESET_DISPLAY_MATCH;
			end
		endcase
	end

	reg[1:0] firstDone;

	always @(*) begin
		generateLetters <= 1'b0;
		enableInput <= 2'd0;
		displayMatch <= 2'd0;
		resetDatapath <= 1'b1;
		resetInput <= 2'b11;
		resetMod <= 2'b11;
		player1Win <= 1'b0;
		player2Win <= 1'b0;
		verify <= 2'd0;
		resetDisplayIndividual <= 2'd0;
		wipeScreen <= 1'b0;
		case(current_state)
			START: begin
				resetDatapath <= 1'b0;
				firstDone <= 2'd0;
				wipeScreen <= 1'b1;
			end
			START_WAIT: begin
				resetDatapath <= 1'b0;
				firstDone <= 2'd0;
			end
			GENERATE_LETTERS: begin
				generateLetters <= 1'b1;
				resetDatapath <= 1'b0;
			end 
			GAMEPLAY: begin
				case(player1_state)
					RESET_DISPLAY_INDIVIDUAL : displayMatch[0] <= 1'b1;
					DISPLAY_MATCH: begin
						displayMatch[0] <= 1'b1;
						resetDisplayIndividual[0] <= 1'b1;
					end
					RESET_INPUT_MODULE: resetMod[0] <= 1'b0 | firstDone[0];
					RESET_INPUT: begin
						resetInput[0] <= 1'b0;
						firstDone[0] <= 1'b1;
					end
					INPUT: enableInput[0] <= 1'b1;
					VERIFY: verify[0] <= 1'b1;
				endcase
				case(player2_state)
					RESET_DISPLAY_INDIVIDUAL : displayMatch[1] <= 1'b1;
					DISPLAY_MATCH: begin
						displayMatch[1] <= 1'b1;
						resetDisplayIndividual[1] <= 1'b1;
					end
					RESET_INPUT_MODULE: resetMod[1] <= 1'b0 | firstDone[1];
					RESET_INPUT: begin
						resetInput[1] <= 1'b0;
						firstDone[1] <= 1'b1;
					end
					INPUT: enableInput[1] <= 1'b1;
					VERIFY: verify[1] <= 1'b1;
				endcase
			end
			PLAYER1_WIN: player1Win <= 1'b1;
			PLAYER2_WIN: player2Win <= 1'b1;
		endcase
	end

	always @(posedge clk) begin
		if (~reset) current_state <= START;
		else current_state <= next_state;
	end
	always @(posedge clk1) begin
		if(~reset) player1_state <= RESET_DISPLAY_MATCH;
		else player1_state <= player1_next;
	end
	always @(posedge clk2) begin
		if (~reset) player2_state <= RESET_DISPLAY_MATCH;
		else player2_state <= player2_next;
	end
endmodule
module inputHandler(clk, reset, keyIn, enable, topY, curCode, x, y, colour, drawEn);
	input clk, reset, keyIn, enable;
	input[6:0] topY;
	output reg[9:0] curCode; //5 2-bit seminibbles (10 = dot, 11 = dash)
	output[7:0] x;
	output[6:0] y;
	output[2:0] colour;
	output drawEn;
	reg[2:0] semiNibblesUsed;
	wire dot, dash, drawDone;
	reg[3:0] position;

	MorseInput m0 (clk, reset, keyIn,drawDone, dot, dash, drawEn);

	displayMorse displayMorse0(clk, reset & drawEn, curCode,8'd10, topY + 7'd20, 3'b111, x, y, colour, drawDone);
	always @(*) begin
		position <= 4'd9 - semiNibblesUsed * 2'd2;
	end

	always @(posedge clk or negedge reset) begin
		if (!reset) begin
			semiNibblesUsed <= 3'd0;
			curCode <= 10'd0;
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

module LFSR(clk, reset, seed, out); //6-bit Fibonacci LFSR
	input clk, reset;
	input[5:0] seed;
	output reg[5:0] out;
	reg[5:0] newbit;

	//Feedback polynomial: x^6 + x^5 + 1 (from wikipedia)
	always @(posedge clk) begin
		if (!reset) begin
			out <= seed;
			newbit <= 6'd0;
		end
		else begin
			newbit <= ((out >> 0) ^ (out >> 1));
			out <= (out >> 1) | (newbit << 5);
			if(out == 6'd0) begin
				out <= seed;
			end
		end
	end
endmodule

module generateRandomLetter(clk, reset, seed, letterCode, valid);
	input clk, reset;
	input [5:0] seed;
	output[5:0] letterCode;
	output valid;
	LFSR lfsr0(clk, reset, seed, letterCode);
	assign valid = (letterCode < 6'd37 & letterCode > 6'd0);
endmodule

module scanToEncodingLUT(scanCode, letterCode);
	input[7:0] scanCode;
	output reg[5:0] letterCode;
	always @(*) begin
		case(scanCode)
			8'h45: letterCode <= 6'd1;
			8'h16: letterCode <= 6'd2;
			8'h1E: letterCode <= 6'd3;
			8'h26: letterCode <= 6'd4;
			8'h25: letterCode <= 6'd5;
			8'h2E: letterCode <= 6'd6;
			8'h36: letterCode <= 6'd7;
			8'h3D: letterCode <= 6'd8;
			8'h3E: letterCode <= 6'd9;
			8'h46: letterCode <= 6'd10;
			8'h1C: letterCode <= 6'd11;
			8'h32: letterCode <= 6'd12;
			8'h21: letterCode <= 6'd13;
			8'h23: letterCode <= 6'd14;
			8'h24: letterCode <= 6'd15;
			8'h2B: letterCode <= 6'd16;
			8'h34: letterCode <= 6'd17;
			8'h33: letterCode <= 6'd18;
			8'h43: letterCode <= 6'd19;
			8'h3B: letterCode <= 6'd20;
			8'h42: letterCode <= 6'd21;
			8'h4B: letterCode <= 6'd22;
			8'h3A: letterCode <= 6'd23;
			8'h31: letterCode <= 6'd24;
			8'h44: letterCode <= 6'd25;
			8'h4D: letterCode <= 6'd26;
			8'h15: letterCode <= 6'd27;
			8'h2D: letterCode <= 6'd28;
			8'h1B: letterCode <= 6'd29;
			8'h2C: letterCode <= 6'd30;
			8'h3C: letterCode <= 6'd31;
			8'h2A: letterCode <= 6'd32;
			8'h1D: letterCode <= 6'd33;
			8'h22: letterCode <= 6'd34;
			8'h35: letterCode <= 6'd35;
			8'h1A: letterCode <= 6'd36;
			default: letterCode <= 6'd0;
		endcase
	end
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
			8'h45:  morseEncoding <= 10'b1111111111; //0
			8'h16:  morseEncoding <= 10'b1011111111; //1
			8'h1E:  morseEncoding <= 10'b1010111111; //2
			8'h26:  morseEncoding <= 10'b1010101111; //3
			8'h25:  morseEncoding <= 10'b1010101011; //4
			8'h2E:  morseEncoding <= 10'b1010101010; //5
			8'h36:  morseEncoding <= 10'b1111010100; //6
			8'h3D:  morseEncoding <= 10'b1111101010; //7
			8'h3E:  morseEncoding <= 10'b1111111100; //8
			8'h46:  morseEncoding <= 10'b1111111110; //9
			8'h1C:  morseEncoding <= 10'b1011000000; //a
			8'h32:  morseEncoding <= 10'b1110101000; //b
			8'h21:  morseEncoding <= 10'b1110111000; //c
			8'h23:  morseEncoding <= 10'b1110100000; //d
			8'h24:  morseEncoding <= 10'b1000000000; //e
			8'h2B:  morseEncoding <= 10'b1010111000; //f
			8'h34:  morseEncoding <= 10'b1111100000; //g
			8'h33:  morseEncoding <= 10'b1010101000; //h
			8'h43:  morseEncoding <= 10'b1010000000; //i
			8'h3B:  morseEncoding <= 10'b1011111100; //j
			8'h42:  morseEncoding <= 10'b1110110000; //k
			8'h4B:  morseEncoding <= 10'b1011101000; //l
			8'h3A:  morseEncoding <= 10'b1111000000; //m
			8'h31:  morseEncoding <= 10'b1110000000; //n
			8'h44:  morseEncoding <= 10'b1111110000; //o
			8'h4D:  morseEncoding <= 10'b1011111000; //p
			8'h15:  morseEncoding <= 10'b1111101100; //q
			8'h2D:  morseEncoding <= 10'b1011100000; //r
			8'h1B:  morseEncoding <= 10'b1010100000; //s
			8'h2C:  morseEncoding <= 10'b1100000000; //t
			8'h3C:  morseEncoding <= 10'b1010110000; //u
			8'h2A:  morseEncoding <= 10'b1010101100; //v
			8'h1D:  morseEncoding <= 10'b1011110000; //w
			8'h22:  morseEncoding <= 10'b1110101100; //x
			8'h35:  morseEncoding <= 10'b1110111100; //y
			8'h1A:  morseEncoding <= 10'b1111101000; //z

			default: morseEncoding <= 10'd0;
		endcase
	end
endmodule

module displayAllMorse(clk, reset, resetIndividual, morseCodes, lettersDone, topY, x, y, colour, doneIndividual, doneAll);
	parameter numLetters = 5;
	parameter numLetterBits = numLetters * 10;
	input clk, reset, resetIndividual;
	input[numLetterBits-1:0] morseCodes;
	input[3:0] lettersDone;
	input[6:0] topY;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	output doneIndividual;
	output reg doneAll;
	reg[numLetterBits-1:0] curMorseCodes;

	wire[9:0] curMorse;
	assign curMorse = curMorseCodes[numLetterBits-1:numLetterBits-10];
	reg [7:0] curTopLeftX;
	reg[3:0] counter;
	reg[2:0] inColour;
	displayMorse displayMorse1(clk, reset & resetIndividual, curMorse, curTopLeftX, topY, inColour, x, y, colour, doneIndividual);

	always @(*) begin
		inColour <= (numLetters - counter -1'b1== lettersDone) ? 3'b100: 3'b111;
	end
	always @(posedge clk) begin
		if(~reset) begin
			counter <= numLetters-1'b1;
			curTopLeftX <= 8'd20;
			doneAll <= 1'b0;
			curMorseCodes <= morseCodes;
		end
		else begin
			if(doneIndividual & resetIndividual) begin
				if(counter == 4'd0) doneAll <= 1'b1;
				else begin
					counter <= counter -1'b1;
					curMorseCodes <= curMorseCodes << 10;
					curTopLeftX <= curTopLeftX + 20;
				end
			end
		end
	end
endmodule

module displayMorse(clk, reset, morseCode, topLeftX, topLeftY, inColour, x, y, colour, done);
	input clk, reset;
	input[9:0] morseCode;
	input[7:0] topLeftX;
	input[6:0] topLeftY;
	input[2:0] inColour;
	output reg[7:0] x;
	output reg[6:0] y;
	output done;
	output [2:0] colour;
	reg[3:0] counter;
	reg curBit;
	reg[9:0] codeToDraw;
	always @(posedge clk) begin
		if (~reset) begin
			curBit <= 1'b0;
			counter <= 4'd9;
			x <= topLeftX;
			y <= topLeftY;
			codeToDraw <= morseCode;
		end
		else begin
			if(curBit) begin
				x <= x + 2'd3;
			end
			else begin
				x <= x + 1'b1;
			end
			curBit <= curBit + 1'b1;
			if(counter == 4'd0) counter <= 4'd9;
			else counter <= counter - 1'b1;

		end
	end
	wire curVal;
	assign curVal = codeToDraw[counter];
	assign colour = curVal ? inColour : 3'b000;
	assign done = (counter == 4'd0);
endmodule
module displayAllLetters(clk, reset, resetIndividual, letterCodes, lettersDone, topY, x, y, colour, doneIndividual, doneAll);
	parameter numLetters = 5;
	parameter numLetterBits = numLetters * 6;
	input clk, reset, resetIndividual;
	input[numLetterBits-1:0] letterCodes;
	input[3:0] lettersDone;
	input[6:0] topY;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	output doneIndividual;
	output reg doneAll;
	wire[14:0] curPattern;
	reg[numLetterBits-1:0] curLetterCodes;
	patternEncoding pattern0(curLetterCodes[numLetterBits-1:numLetterBits-6], curPattern);

	reg [7:0] curTopLeftX;
	reg[3:0] counter;
	reg[2:0] inColour;
	displayLetter displayLetter0(clk, reset & resetIndividual, curPattern, curTopLeftX, topY, inColour, x, y, colour, doneIndividual);

	always @(*) begin
		inColour <= (numLetters - counter -1'b1== lettersDone) ? 3'b100: 3'b111;
	end
	always @(posedge clk) begin
		if(~reset) begin
			counter <= numLetters-1'b1;
			curTopLeftX <= 8'd20;
			doneAll <= 1'b0;
			curLetterCodes <= letterCodes;
		end
		else begin
			if(doneIndividual) begin
				if(counter == 1'b0) begin
					doneAll <= 1'b1;
				end
				else begin
					counter <= counter -1'b1;
					curLetterCodes <= curLetterCodes << 6;
					curTopLeftX <= curTopLeftX + 6;
				end
			end
		end
	end
endmodule

module displayLetter(clk, reset, pixelPattern, topLeftX,topLeftY, inColour, x, y, colour, done);
	input clk, reset;
	input [0:14] pixelPattern;
	input [7:0] topLeftX;
	input[6:0] topLeftY;
	input[2:0] inColour;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour;
	output done;
	reg[4:0] counter;

	always @(posedge clk) begin
		if(~reset) begin
			x <= topLeftX -1'b1;
			counter <= 5'd1;
			y <= topLeftY;
			colour <= 3'b000;
		end
		else begin
			if(counter != 5'd0) begin
				if(pixelPattern[counter-1'b1] == 1'b0) begin
					colour <= 3'b000;
				end
				else colour <= inColour;
				if(x-topLeftX + 1'd1 >= 3'd3) begin
					x <= topLeftX;
					y <= y+1'b1;
				end
				else x <= x + 1'b1;
			end
			if(counter == 5'b10000) counter <= 5'd1;
			else counter <= counter + 1'b1;
		end
	end
	assign done = counter == 5'b10000;
endmodule

module patternEncoding(letterCode, pixelPattern);
	input [5:0] letterCode;
	output reg [0:14] pixelPattern;

	always @(*) begin
		case(letterCode)
			6'd1: pixelPattern <= 15'b111_101_101_101_111; //0
			6'd2: pixelPattern <= 15'b010_110_010_010_111; //1
			6'd3: pixelPattern <= 15'b111_001_111_100_111; //2
			6'd4: pixelPattern <= 15'b111_001_111_001_111; //3
			6'd5: pixelPattern <= 15'b101_101_111_001_001; //4
			6'd6: pixelPattern <= 15'b111_100_111_001_111; //5
			6'd7: pixelPattern <= 15'b111_100_111_101_111; //6
			6'd8: pixelPattern <= 15'b111_001_001_001_001; //7
			6'd9: pixelPattern <= 15'b111_101_111_101_111; //8
			6'd10: pixelPattern <= 15'b111_101_111_001_001; //9
			6'd11: pixelPattern <= 15'b010_101_111_101_101; //A
			6'd12: pixelPattern <= 15'b110_101_110_101_110; //B
			6'd13: pixelPattern <= 15'b010_101_100_101_010; //C
			6'd14: pixelPattern <= 15'b110_101_101_101_110; //D
			6'd15: pixelPattern <= 15'b111_100_111_100_111; //E
			6'd16: pixelPattern <= 15'b111_100_111_100_100; //F
			6'd17: pixelPattern <= 15'b011_100_100_101_011; //G
			6'd18: pixelPattern <= 15'b101_101_111_101_101; //H
			6'd19: pixelPattern <= 15'b010_010_010_010_010; //I
			6'd20: pixelPattern <= 15'b001_001_001_101_010; //J
			6'd21: pixelPattern <= 15'b101_101_110_101_101; //K
			6'd22: pixelPattern <= 15'b100_100_100_100_111; //L
			6'd23: pixelPattern <= 15'b101_111_101_101_101; //M
			6'd24: pixelPattern <= 15'b110_101_101_101_101; //N
			6'd25: pixelPattern <= 15'b010_101_101_101_010; //O
			6'd26: pixelPattern <= 15'b110_101_110_100_100; //P
			6'd27: pixelPattern <= 15'b010_101_101_111_011; //Q
			6'd28: pixelPattern <= 15'b110_101_110_101_101; //R
			6'd29: pixelPattern <= 15'b011_100_010_001_110; //S
			6'd30: pixelPattern <= 15'b111_010_010_010_010; //T
			6'd31: pixelPattern <= 15'b101_101_101_101_111; //U
			6'd32: pixelPattern <= 15'b101_101_101_101_010; //V
			6'd33: pixelPattern <= 15'b101_101_101_111_101; //W
			6'd34: pixelPattern <= 15'b101_101_010_101_101; //X
			6'd35: pixelPattern <= 15'b101_101_111_010_010; //Y
			6'd36: pixelPattern <= 15'b111_001_010_100_111; //Z
			default: pixelPattern <= 15'b000_000_000_000_000; //blank display
		endcase
	end
endmodule

module MorseInput(clk,reset, keyIn, drawDone, dot, dash, drawEn);
	input clk, reset, keyIn, drawDone;

	output reg dot, dash, drawEn;
	localparam S_WAIT = 3'd0,
	S_KEYDOWN = 3'd1,
	S_KEYUP = 3'd2,
	S_RESET = 3'd3,
	S_DRAW = 3'd4;

	reg[2:0] current_state, next_state;

	always @(*)
		begin
			case(current_state)
				S_WAIT : next_state = keyIn ? S_WAIT : S_KEYDOWN;
				S_KEYDOWN : next_state = keyIn ? S_KEYUP: S_KEYDOWN;
				S_KEYUP :next_state = S_RESET;
				S_RESET : next_state = S_DRAW;
				S_DRAW : next_state = drawDone ? S_WAIT : S_DRAW;
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
			drawEn <= 1'b0;
			case(current_state)
				S_KEYDOWN : resetInputCounter <= 1'b1;
				S_KEYUP :
					begin
						if(enableDash) dash <= 1'b1;
						else dot <= 1'b1;
					end
				S_DRAW: drawEn <= 1'b1;
				default: dot <= 1'b0;
			endcase
		end

	always @(posedge clk)
		begin
			if(!reset) current_state = S_WAIT;
			else current_state = next_state;
		end
endmodule

module inputCounter(clk, reset, enableDash);
	input clk, reset;
	output enableDash;
	reg[27:0] q;
	always @(posedge clk)
		begin
			if(!reset) q <= 0;
			else begin
				if(q + 1'b1 == 0) begin //overflow
					// q <= 26'b10111110101111000010000000;
					q <= 25'd5;
				end
				q <= q + 1'b1;

			end
		end
	// assign enableDash = q >= 26'b10111110101111000010000000 ? 1'b1 : 1'b0;
	assign enableDash = q >= 25'd5;
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

	// PS2_Controller #(.INITIALIZE_MOUSE(0)) core_driver (
	//     .CLOCK_50       (clk),
	//     .reset          (~reset     ),
	//     .PS2_CLK        (PS2_CLK    ),
	//     .PS2_DAT        (PS2_DAT    ),
	//     .received_data   (newest_byte  ),
	//      .received_data_en(byte_received)
	// );

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
endmodule

module hex_decoder(hex_digit, segments);
	input [3:0] hex_digit;
	output reg [6:0] segments;

	always @(*)
		case (hex_digit)
			4'h0: segments = 7'b100_0000;
			4'h1: segments = 7'b111_1001;
			4'h2: segments = 7'b010_0100;
			4'h3: segments = 7'b011_0000;
			4'h4: segments = 7'b001_1001;
			4'h5: segments = 7'b001_0010;
			4'h6: segments = 7'b000_0010;
			4'h7: segments = 7'b111_1000;
			4'h8: segments = 7'b000_0000;
			4'h9: segments = 7'b001_1000;
			4'hA: segments = 7'b000_1000;
			4'hB: segments = 7'b000_0011;
			4'hC: segments = 7'b100_0110;
			4'hD: segments = 7'b010_0001;
			4'hE: segments = 7'b000_0110;
			4'hF: segments = 7'b000_1110;
			default: segments = 7'h7f;
		endcase
endmodule