vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf displayAllLetters -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {resetIndividual} 0
force {letterCodes} 2#011011011011011011011011011011
force {lettersDone} 2#0
force {topY} 2#001100
run 10ns

force {reset} 1
force {resetIndividual} 1
run 160ns

force {resetIndividual} 0
run 10ns

force {resetIndividual} 1
run 200ns
