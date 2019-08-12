vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf inputHandler -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {keyIn} 1
force {enable} 1
force {topY} 2#110000
run 10ns

force {reset} 1
force {keyIn} 0
run 100ns

force {keyIn} 1
run 150ns

force {keyIn} 0
run 20ns

force {keyIn} 1
run 150ns

force {keyIn} 0
run 20ns
force {keyIn} 1
run 150ns
force {keyIn} 0
run 20ns
force {keyIn} 1
run 150ns

force {keyIn} 0
run 110ns
force {keyIn} 1
run 150ns


force {keyIn} 0
run 110ns
force {keyIn} 1
run 300ns
