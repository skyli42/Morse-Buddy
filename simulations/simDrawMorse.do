vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf displayMorse -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {morseCode} 2#1110101111 # - . . - -
run 10ns
force {reset} 1
force {morseCode} 2#0000000000
run 200ns