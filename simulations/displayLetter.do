vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf displayLetter -t ns


log {/*}
add wave {/*}

force {clk} 1 0ns, 0 5ns -repeat 10ns


force {reset} 0
force {pixelPattern} 2#010101101111011
force {topLeftX} 2#00001000
force {topLeftY} 10#5
force {inColour} 2#111
run 10ns

force {reset} 1
run 160ns

force {reset} 0
run 10ns

force {reset} 1
run 200ns
