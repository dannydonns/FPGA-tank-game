# ============================================================
# ModelSim / Questa DO FILE for full_game_runs_tb
# ============================================================

# Fresh work library
vlib work
vmap work work

# ------------------------------------------------------------
# Compile design files
# ------------------------------------------------------------
vcom -2008 counter.vhd
vcom -2008 score.vhd
vcom -2008 full_game_runs_tb.vhd

# ------------------------------------------------------------
# Start simulation
# ------------------------------------------------------------
vsim -voptargs=+acc work.full_game_runs

# ------------------------------------------------------------
# Add waves
# ------------------------------------------------------------

# Clock / reset / pls_clk
add wave -divider "Clock + Reset"
add wave sim:/full_game_runs/clk
add wave sim:/full_game_runs/pls_clk
add wave sim:/full_game_runs/rst

# Inputs
add wave -divider "Inputs"
add wave sim:/full_game_runs/c1
add wave sim:/full_game_runs/c2

# Score outputs (unsigned radix)
add wave -divider "Score Outputs"
add wave -radix unsigned sim:/full_game_runs/score1
add wave -radix unsigned sim:/full_game_runs/score2
add wave sim:/full_game_runs/w1
add wave sim:/full_game_runs/w2

# Internal DUT waveform visibility
add wave -divider "Score DUT Internals"
add wave sim:/full_game_runs/DUT/*

# ------------------------------------------------------------
# Run simulation
# ------------------------------------------------------------
run -all
