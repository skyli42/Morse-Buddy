vlib work

vlog -timescale 1ns/1ns test.v

vsim -L altera_mf_ver -L altera_mf test -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
run 10ns

force {reset} 1
run 100ns
