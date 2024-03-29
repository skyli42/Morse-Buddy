vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf MorseInput -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {keyIn} 1
force {drawDone} 0
run 10ns

force {reset} 1
force {keyIn} 0
run 150ns

force {keyIn} 1
run 10ns
force {drawDone} 1
run 20ns
force {keyIn} 0
force {drawDone} 0
run 20ns

force {keyIn} 1
run 40ns
