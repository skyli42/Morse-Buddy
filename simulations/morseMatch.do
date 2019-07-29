vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf morseMatch -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {morseCodes} 2#11101010111000000000
force {keyIn} 1
force {enableInput} 1
force {verify} 0
force {resetInput} 1
run 10ns

force {reset} 1
force {keyIn} 0
run 150ns

force {keyIn} 1
run 30ns

force {keyIn} 0
run 20ns

force {keyIn} 1
run 40ns

force {keyIn} 0
run 20ns
force {keyIn} 1
run 20ns
force {keyIn} 0
run 20ns
force {keyIn} 1
run 20ns

force {keyIn} 0
run 110ns
force {keyIn} 1
run 30ns

force {keyIn} 0
run 110ns
force {keyIn} 1
force {verify} 1
run 10ns

force {resetInput} 0
force {verify} 0
run 10ns
force {resetInput} 1
run 10ns
force {keyIn} 0
run 200ns
force {keyIn} 1
run 40ns
force {verify} 1
run 10ns
force {resetInput} 0
force {verify} 0
run 10ns
force {resetInput} 1
run 10ns

force {keyIn} 0
run 20ns
force {keyIn} 1
run 40ns
force {verify} 1
run 10ns
force {resetInput} 0
force {verify} 0
run 10ns
force {resetInput} 1
run 100ns
