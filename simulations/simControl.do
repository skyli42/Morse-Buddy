vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf control -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {seed} 2#00010
force {start} 1
force {submit} 1
force {validationDone} 0
force {correct} 0
force {continue} 1
run 10ns

force {reset} 1
force {start} 0
run 20ns

force {start} 1
run 50ns

force {submit} 0
run 10ns

force {submit} 1
run 10ns

force {validationDone} 1
run 10ns

force {validationDone} 0
force {continue} 1
run 10ns