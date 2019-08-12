vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf gameManager -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {seed} 2#110110
force {keyIn1} 1
force {keyIn2} 1
force {proceed1} 1
force {proceed2} 1
force {mode} 0
run 10ns

force {reset} 1
run 100ns

force {proceed1} 0
run 10ns
force {proceed1} 1
run 2500ns

#letter 1

force {keyIn1} 0
force {keyIn2} 0 
run 50ns

force {keyIn1} 1
run 50ns

force {keyIn2} 1
run 300ns

force {proceed1} 0
run 10ns

force {proceed1} 1
force {keyIn2} 0 
force {keyIn1} 0
run 200ns

force {keyIn1} 1
force {keyIn2} 1
run 300ns 

force {keyIn1} 0
force {keyIn2} 0
run 50ns

force {keyIn2} 1 
run 60ns

force {keyIn1} 1
run 300ns

force {keyIn1} 0
force {keyIn2} 0
run 50ns

force {keyIn1} 1 
run 60ns

force {keyIn2} 1
run 300ns

force {proceed2} 0
run 10ns

force {keyIn1} 0
run 20ns

force {proceed2} 1
run 100ns 

force {keyIn1} 1
run 300ns

force {proceed1} 0
run 10ns
force {proceed1} 1
run 2500ns 

force {keyIn1} 0
force {keyIn2} 0
run 110ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 110ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns

force {proceed1} 0
force {proceed2} 0
run 20ns

force {proceed1} 1
force {proceed2} 1
run 2500ns

# letter 3
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {proceed1} 0
force {proceed2} 0
run 20ns

force {proceed1} 1
force {proceed2} 1
run 2500ns

# letter 4
force {keyIn1} 0
force {keyIn2} 0
run 150ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 150ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 150ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns

force {proceed1} 0
force {proceed2} 0
run 20ns

force {proceed1} 1
force {proceed2} 1
run 2500ns

# letter 5
force {keyIn1} 0
force {keyIn2} 0
run 150ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {keyIn1} 0
force {keyIn2} 0
run 50ns
force {keyIn1} 1
force {keyIn2} 1
run 300ns
force {proceed1} 0
force {proceed2} 0
run 20ns

force {proceed1} 1
force {proceed2} 1
run 2500ns