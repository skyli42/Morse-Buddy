vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf MorseBuddy -t ns


log {/*}
add wave {/*}

force {CLOCK_50} 1 0ns, 0 5ns -repeat 10ns


# reset
force {KEY} 2#1110
force {SW} 2#0001101101
run 10ns

force {KEY} 2#1111
run 50ns

force {KEY} 2#0111
run 10ns

force {KEY} 2#1111
run 1300ns


# letter 1
force {KEY} 2#1101
run 50ns

force {KEY} 2#1111
run 500ns

force {KEY} 2#1101
run 200ns

force {KEY} 2#1111
run 500ns

force {KEY} 2#1101
run 50ns

force {KEY} 2#1111
run 500ns

force {KEY} 2#1101
run 50ns

force {KEY} 2#1111
run 500ns

force {KEY} 2#0111
run 20ns

force {KEY} 2#1111
run 1300ns

#letter 2
force {KEY} 2#1101
run 10ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 10ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#0111
run 20ns

force {KEY} 2#1111
run 1200ns

# letter 3
force {KEY} 2#1101
run 150ns

force {KEY} 2#1111
run 500ns

force {KEY} 2#0111
run 10ns
force {KEY} 2#1111
run 1200ns


# letter 4
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 50ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns


force {KEY} 2#0111
run 10ns
force {KEY} 2#1111
run 1200ns

#letter 5
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 50ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 150ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 50ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#1101
run 50ns
force {KEY} 2#1111
run 500ns
force {KEY} 2#0111
run 10ns
force {KEY} 2#1111
force {SW} 2#1001101101

run 50ns

force {KEY} 2#0111
run 10ns
force {KEY} 2#1111
run 50ns
force {KEY} 2#0111
run 10ns
force {KEY} 2#1111
run 1200ns