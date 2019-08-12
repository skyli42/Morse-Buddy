vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf control -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns
force {clk1} 1 0ns, 0 10ns -repeat 20ns
force {clk1} 0 0ns, 1 10ns -repeat 20ns


force {reset} 0
force {proceed} 2#11
force {doneGeneratingLetters} 0
force {finishedAllVerification} 2#00
force {correct} 2#00
force {doneDrawIndividual} 2#00
force {doneDrawAll} 2#00
run 20ns

force {reset} 1
force {proceed} 2#10
run 20ns
force {proceed} 2#11
run 100ns
force {doneGeneratingLetters} 1
run 20ns
force {doneGeneratingLetters} 0
run 150ns

force {doneDrawIndividual} 2#11
run 20ns

force {doneDrawIndividual} 2#00
run 50ns
force {doneDrawIndividual} 2#11
force {doneDrawAll} 2#11
run 10ns

force {doneDrawIndividual} 2#00
force {doneDrawAll} 2#00
run 50ns

force {proceed} 2#10
force {correct} 2#01
run 10ns
force {proceed} 2#11
run 50ns

force {proceed} 2#01
run 10ns

force {proceed} 2#11
run 50ns

force {proceed} 2#10
force {correct} 2#01
force {finishedAllVerification} 2#01
run 10ns
force {proceed} 2#11
run 50ns

force {proceed} 2#01
run 10ns
force {proceed} 2#11
run 20ns