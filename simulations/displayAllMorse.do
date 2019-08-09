vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf displayAllMorse -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {resetIndividual} 0
force {morseCodes} 2#10101100001111111111111000000010000000001011111000
force {lettersDone} 0
run 10ns

force {reset} 1
force {resetIndividual} 1
run 160ns

force {resetIndividual} 0
force {lettersDone} 2#0001
run 10ns

force {resetIndividual} 1
run 200ns
