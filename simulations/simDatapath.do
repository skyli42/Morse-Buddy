vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf datapath -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {generateLetters} 0
force {displayLetters} 0
force {morseInput} 0
force {resetMorseInput} 0
force {keyIn} 1
force {proceed} 1
force {verify} 0
force {seed} 2#110110
run 10ns

force {reset} 1
force {generateLetters} 1
run 150ns

force {displayLetters} 1
force {generateLetters} 0
run 150ns

force {resetDrawIndividual} 0
run 10ns

force {resetDrawIndividual} 1
run 150ns