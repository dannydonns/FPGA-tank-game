# ============================================================
# ModelSim DO FILE for bullet_collision_tb (decimal radix)
# ============================================================

vlib work
vmap work work

# ------------------------------------------------------------
# Compile design files
# ------------------------------------------------------------
vcom -2008 counter.vhd
vcom -2008 bullet.vhd
vcom -2008 collision.vhd
vcom -2008 bullet_collision_tb.vhd

# ------------------------------------------------------------
# Launch simulation
# ------------------------------------------------------------
vsim -voptargs=+acc work.bullet_collision_tb

# ------------------------------------------------------------
# Add waves
# ------------------------------------------------------------

# Clock/reset
add wave -divider "Clocking"
add wave sim:/bullet_collision_tb/clk
add wave sim:/bullet_collision_tb/pls_clk
add wave sim:/bullet_collision_tb/rst

# Fire + direction
add wave -divider "Fire Controls"
add wave sim:/bullet_collision_tb/fire
add wave sim:/bullet_collision_tb/direction

# Shooter position
add wave -divider "Shooter Position"
add wave -radix decimal sim:/bullet_collision_tb/shooter_x
add wave -radix decimal sim:/bullet_collision_tb/shooter_y

# Target position
add wave -divider "Target Position"
add wave -radix decimal sim:/bullet_collision_tb/target_x
add wave -radix decimal sim:/bullet_collision_tb/target_y

# Bullet signals
add wave -divider "Bullet Signals"
add wave sim:/bullet_collision_tb/bullet_active
add wave -radix decimal sim:/bullet_collision_tb/bullet_x
add wave -radix decimal sim:/bullet_collision_tb/bullet_y

# Collision outputs
add wave -divider "Collision Detection"
add wave sim:/bullet_collision_tb/coll
add wave sim:/bullet_collision_tb/hit_seen

# Bullet internals (decimal where applicable)
add wave -divider "Bullet Internals"
add wave -radix decimal sim:/bullet_collision_tb/BULLET_DUT/*
    
# Collision internals
add wave -divider "Collision Internals"
add wave -radix decimal sim:/bullet_collision_tb/COLLISION_DUT/*

# ------------------------------------------------------------
# Run simulation
# ------------------------------------------------------------
run -all
