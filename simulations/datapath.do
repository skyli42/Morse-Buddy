vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf datapath -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns

force {reset} 0
force {morseCodes} 2#11101011001110101100111010110011101011001110101100
force {letterCodes} 2#100010100010100010100010100010
force {displayMatch} 0
force {resetDrawIndividual} 0
force {enableInput} 0
force {resetInput} 0
force {resetMod} 0
force {keyIn} 1
force {verify} 0
force {mode} 0
run 10ns

force {reset} 1
run 100ns
force {displayMatch} 1
force {resetDrawIndividual} 1
run 1000ns

force {displayMatch} 0
force {resetDrawIndividual} 0
force {enableInput} 1
force {resetMod} 1
force {resetInput} 1
run 10ns

force {keyIn} 0
run 150ns
force {keyIn} 1
run 500ns

