vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf control -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {proceed} 1
force {mode} 0
force {doneGeneratingLetters} 0
force {doneDrawLetters} 0
force {finishedAllVerification} 0
force {correct} 0
run 10ns

force {reset} 1
force {proceed} 0
run 10ns

force {proceed} 1
run 10ns

force {doneGeneratingLetters} 1
run 10ns

force {doneGeneratingLetters} 0
force {doneDrawLetters} 1
run 30ns

force {doneDrawLetters} 0
force {proceed} 0
run 10ns

force {proceed} 1
run 10ns

force {correct} 1
run 10ns

force {correct} 0
force {proceed} 0
run 10ns
force {proceed} 1
run 10ns

force {proceed} 0
run 10ns

force {proceed} 1
run 10ns

force {correct} 1
force {finishedAllVerification} 1
run 10ns

force {correct} 0
force {finishedAllVerification} 0
force {proceed} 0
run 10ns

force {proceed} 1
run 50ns

