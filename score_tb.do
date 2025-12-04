# ============================================================
# ModelSim/Questa DO FILE for score_tb
# ============================================================

# Clean previous work
vlib work
vmap work work

# ------------------------------------------------------------
# Compile sources
# ------------------------------------------------------------
# Adjust these as needed — list ALL your VHDL source files
vcom -2008 score.vhd
vcom -2008 counter.vhd
vcom -2008 score_tb.vhd

# ------------------------------------------------------------
# Launch simulation
# ------------------------------------------------------------
vsim -voptargs=+acc work.score_tb

# ------------------------------------------------------------
# Add waves
# ------------------------------------------------------------

# Top-level signals
add wave -divider "Top Testbench Signals"
add wave sim:/score_tb/clk_100
add wave sim:/score_tb/pls_clk
add wave sim:/score_tb/rst
add wave sim:/score_tb/c1
add wave sim:/score_tb/c2
add wave sim:/score_tb/score1
add wave sim:/score_tb/score2
add wave sim:/score_tb/w1
add wave sim:/score_tb/w2

# SCORE DUT internal signals (optional, remove if not needed)
add wave -divider "SCORE Internals"
add wave sim:/score_tb/SCORE_DUT/*

# ------------------------------------------------------------
# Run the simulation
# ------------------------------------------------------------
run -all
