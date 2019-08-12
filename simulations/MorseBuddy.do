vlib work

vlog -timescale 1ns/1ns ../MorseBuddy.v

vsim -L altera_mf_ver -L altera_mf MorseBuddy -t ns


log {/*}
add wave {/*}

force {CLOCK_50} 1 0ns, 0 5ns -repeat 10ns


# reset
force {KEY} 2#1111
force {SW} 2#0000110110
run 10ns

force {SW} 2#0100110110
run 100ns

force {KEY} 2#1101
run 10ns
force {KEY} 2#1111
run 2500ns


#letter 1
force {KEY} 2#0110
run 50ns
force {KEY} 2#0111
run 50ns

force {KEY} 2#1111
run 300ns

force {KEY} 2#1101
run 10ns

force {KEY} 2#0110
run 200ns

force {KEY} 2#1111
run 300ns 

force {KEY} 2#0110
run 50ns

force {KEY} 2#1110
run 60ns

force {KEY} 2#1111
run 300ns

force {KEY} 2#0110
run 50ns

force {KEY} 2#0111
run 60ns

force {KEY} 2#1111
run 300ns

# player 2 done with letter 1

force {KEY} 2#1011
run 10ns

force {KEY} 2#1010
run 20ns

force {KEY} 2#1110
run 100ns 

force {KEY} 2#1111
run 300ns

force {KEY} 2#1101
run 10ns
force {KEY} 2#1111
run 2400ns 
# both done with letter 1

#letter 2
force {KEY} 2#0110
run 110ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110
run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110
run 150ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110
run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#1101
run 20ns

force {KEY} 2#1011
run 20ns
force {KEY} 2#1111
run 2500ns

# letter 3
force {KEY} 2#0110
run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111
run 300ns
force {KEY} 2#1001
run 20ns
force {KEY} 2#1111
run 2500ns

# letter 4
force {KEY} 2#0110

run 150ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#0110

run 150ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#0110

run 150ns
force {KEY} 2#1111

run 300ns

force {KEY} 2#1001

run 20ns

force {KEY} 2#1111

run 2500ns

# letter 5
force {KEY} 2#0110

run 150ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#0110

run 50ns
force {KEY} 2#1111

run 300ns
force {KEY} 2#1001

run 20ns

force {KEY} 2#1111

run 2500ns