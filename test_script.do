# ------------------------------------------------------------
# Load design
# ------------------------------------------------------------
quit -sim
vsim work.tank_game_tb

# ------------------------------------------------------------
# Add interesting signals
# ------------------------------------------------------------
add wave -divider {Clocks}
add wave /tank_game_tb/clk_50
add wave /tank_game_tb/DUT/clk_100
add wave /tank_game_tb/DUT/counter_pulse

add wave -divider {Key Inputs (forced)}
add wave /tank_game_tb/DUT/key_A_raw
add wave /tank_game_tb/DUT/key_S_raw
add wave /tank_game_tb/DUT/key_K_raw
add wave /tank_game_tb/DUT/key_L_raw
add wave /tank_game_tb/DUT/r_pressed

add wave -divider {Tanks and Bullets}
add wave /tank_game_tb/DUT/tank1x
add wave /tank_game_tb/DUT/tank1y
add wave /tank_game_tb/DUT/tank2x
add wave /tank_game_tb/DUT/tank2y
add wave /tank_game_tb/DUT/bullet1x
add wave /tank_game_tb/DUT/bullet1y
add wave /tank_game_tb/DUT/bullet2x
add wave /tank_game_tb/DUT/bullet2y

add wave -divider {Collisions and Score}
add wave /tank_game_tb/DUT/hit_1_on_2
add wave /tank_game_tb/DUT/hit_2_on_1
add wave /tank_game_tb/DUT/score1_sig
add wave /tank_game_tb/DUT/score2_sig
add wave /tank_game_tb/DUT/w1_sig
add wave /tank_game_tb/DUT/w2_sig
add wave /tank_game_tb/one_wins
add wave /tank_game_tb/two_wins

add wave -divider {LCD}
add wave /tank_game_tb/lcd_rs_out
add wave /tank_game_tb/lcd_e_out
add wave /tank_game_tb/lcd_on_out
add wave /tank_game_tb/data_bus_out



# ------------------------------------------------------------
# Reset sequence
# ------------------------------------------------------------
force /tank_game_tb/global_reset 1 0 ns, 0 500 us

# ------------------------------------------------------------
# Key spam: LOTS of presses, starting early
# (times are absolute; pulses are ~200 µs wide, spaced 400–600 µs)
# Tank1 move (S) and fire (A)
force /tank_game_tb/DUT/key_S_raw 0 0 ns, \
    1 600 us, 0 800 us, \
    1 1.2 ms, 0 1.4 ms, \
    1 1.8 ms, 0 2.0 ms, \
    1 2.4 ms, 0 2.6 ms, \
    1 3.0 ms, 0 3.2 ms, \
    1 3.6 ms, 0 3.8 ms, \
    1 4.2 ms, 0 4.4 ms

force /tank_game_tb/DUT/key_A_raw 0 0 ns, \
    1 700 us, 0 900 us, \
    1 1.3 ms, 0 1.5 ms, \
    1 1.9 ms, 0 2.1 ms, \
    1 2.5 ms, 0 2.7 ms, \
    1 3.1 ms, 0 3.3 ms, \
    1 3.7 ms, 0 3.9 ms, \
    1 4.3 ms, 0 4.5 ms

# Tank2 move (L) and fire (K)
force /tank_game_tb/DUT/key_L_raw 0 0 ns, \
    1 800 us, 0 1.0 ms, \
    1 1.4 ms, 0 1.6 ms, \
    1 2.0 ms, 0 2.2 ms, \
    1 2.6 ms, 0 2.8 ms, \
    1 3.2 ms, 0 3.4 ms, \
    1 3.8 ms, 0 4.0 ms, \
    1 4.4 ms, 0 4.6 ms

force /tank_game_tb/DUT/key_K_raw 0 0 ns, \
    1 900 us, 0 1.1 ms, \
    1 1.5 ms, 0 1.7 ms, \
    1 2.1 ms, 0 2.3 ms, \
    1 2.7 ms, 0 2.9 ms, \
    1 3.3 ms, 0 3.5 ms, \
    1 3.9 ms, 0 4.1 ms, \
    1 4.5 ms, 0 4.7 ms

# Game reset (R) later, after score/win
force /tank_game_tb/DUT/r_pressed 0 0 ns, 1 15 ms, 0 15.3 ms

# ------------------------------------------------------------
# Run long enough to see movement, bullets, collisions, score & reset
# (counter_pulse is slow: 5 ms per tick, so we need a decent run)
# ------------------------------------------------------------
run 40 ms
