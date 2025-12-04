# =========================================================
# Reset DUT
# =========================================================
force /tank_game_tb/DUT/global_reset 1
run 100ns
force /tank_game_tb/DUT/global_reset 0

# =========================================================
# Simulate tank movement (S = tank1, L = tank2)
# =========================================================
force /tank_game_tb/DUT/key_S_raw 1 1ms, 0 3ms
force /tank_game_tb/DUT/key_L_raw 1 1.5ms, 0 3.5ms

# =========================================================
# Fire tank1 bullet 3 times (A key)
# =========================================================
force /tank_game_tb/DUT/key_A_raw 1 4ms, 0 4.2ms, 1 5ms, 0 5.2ms, 1 6ms, 0 6.2ms

# =========================================================
# Fire tank2 bullet once (K key)
# =========================================================
force /tank_game_tb/DUT/key_K_raw 1 7ms, 0 7.2ms

# =========================================================
# Press R to reset game
# =========================================================
force /tank_game_tb/DUT/r_pressed 1 9ms, 0 9.3ms

# =========================================================
# Run simulation long enough to see bullets fly, collisions, scores, and reset
# =========================================================
run 20ms
