vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf datapath -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {keyIn} 1
force {pollLetter} 0
force {morseEn} 0
force {letterDisp} 0
force {checkAnswer} 0
force {letterCode} 2#001111
run 20ns

force {reset} 1
force {pollLetter} 1
run 10ns


force {pollLetter} 0
force {morseEn} 1
run 10ns

force {keyIn} 0
run 20ns

force {keyIn} 1
run 10ns

force {checkAnswer} 1
run 30ns

force {morseEn} 0
run 10ns
