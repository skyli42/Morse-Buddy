MorseBuddy allows you to compete with a friend to test your ability to translate alphanumeric text to morse code, with display on the monitor and a singleplayer mode translating morse code to alphanumeric test.

Top level module: MorseBuddy (located in MorseBuddy.v)

Project modules:
	MorseBuddy: The top-level module - it connects the FPGA board / pins and VGA adapter to gameManager, which houses the game logic.

	gameManager: The major game module - it connects two datapaths and a control unit together (one datapath per player), and also manages VGA output.

	clock_offsetter: A simple module that creates two half-speed clocks that are desynchronized so that the VGA outputs of the two player datapaths don't interfere with each other.

	datapath: The major logic unit - it connects modules to match input from both keyIn and from the Keyboard, as well as display the text to match and the current input.

	wipeScreen: A simple module that's used to clear the screen to all black.

	keyboardMatch: The module that manages keyboard input using keyboard_handler and checks it for correctness. It also provides logic to display the current keyboard input on the VGA display.

	morseMatch: The module that manages key input (for morse code) using inputHandler and check for correctness. It also provides logic to display the current morse code input on the VGA display.

	control: The control unit - contains three FSM's, one main FSM and one for each player. It takes in input signals from the datapaths and also provides control signals to the datapaths.

	inputHandler: The module that directly handles morse code input. It is used by morseMatch, and uses MorseInput in order to detect what the current input is (dot vs dash), and it also uses displayMorse for the logic to display the current input on the VGA display.

	LFSR: A module that runs a 6-bit Fibonacci LFSR algorithm from wikipedia for pseudo-random number generation. Its feedback polynomial is x^6 + x^5 + 1. The implementaion and feedback polynomial were sourced from Wikipedia.

	generateRandomLetter: The module that generates pseudo-random letters for the player to try and match. It uses the LFSR unit for random number generation.

	scanToEncodingLUT: A lookup table to convert keyboard scan codes into internal keycodes.

	encodingToScanLUT: A lookup table to convert internal keycodes into keyboard scan codes.

	scanToMorseLUT: A lookup table to convert keyboard scan codes into encoded morse.

	displayAllMorse: Provides the logic to display a sequence of morse codes on a VGA display, with one highlighted. It uses displayMorse for each individual letter. In the context of the game, the highlighted code is the one that the player has to try and match.

	displayMorse: Provides the logic to display a single morse code (5 dots/dashes) on a VGA display.

	displayAllLetters: Provides the logic to display a sequence of letters on a VGA display, with one highlighted. It uses displayLetter for each individual letter, and patternEncoding in order to convert the internal keycode to a pattern of pixels for displayLetter. In the context of the game, the highlighted letter is the one that the player has to try and match.

	displayLetter: Provides the logic to display a pixelPattern that displays a 5x3 letter on a VGA display.

	patternEncoding: A lookup table to convert internal keycodes into a 15 bit pattern that represents how letters should be displayed.

	MorseInput: A module that outputs a signal whenever a morse input is read, along with whether or not it's a dash or a dot. Uses inputCounter to determine dash vs dot.

	inputCounter: A simple counter used by MorseInput to determine if an input is a dash or not.

	keyboard_handler: A module that outputs a signal whenever a key is pressed on the PS2 keyboard, along with a scan code. Uses the PS2_Controller provided in the project resources (from Alex Hurka). This is based on the example code provided in the same resource folder.

	hex_decoder: A decoder to allow display of 4-bit signals on the HEX displays. Taken from previous labs / class.

Other Verilog Modules:
	vga_adapter, vga_address_translator, vga_controller, vga_pll - These were taken from Lab 7, and are just used for VGA output.
	Altera_UP_PS2_Command_Out, Altera_UP_PS2_Data_In, PS2_Controller - These were taken from Alex Hurka's keyboard resource from the course website.

Resources:
