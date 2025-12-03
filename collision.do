# ------------------------------------------------------------
# Clean and compile
# ------------------------------------------------------------
quit -sim
vlib work
vmap work work

# Compile DUT files
vcom bullet.vhd
vcom collision.vhd

# Compile testbench
vcom bullet_collision_tb.vhd

# ------------------------------------------------------------
# Run simulation
# ------------------------------------------------------------
vsim work.bullet_collision_tb

# ------------------------------------------------------------
# Add waveform signals
# ------------------------------------------------------------

# Top-level testbench signals
add wave -divider {Testbench Control}
add wave sim:/bullet_collision_tb/clk
add wave sim:/bullet_collision_tb/rst
add wave sim:/bullet_collision_tb/fire
add wave sim:/bullet_collision_tb/direction

# Positions
add wave -divider {Positions}
add wave -radix unsigned sim:/bullet_collision_tb/shooter_x
add wave -radix unsigned sim:/bullet_collision_tb/shooter_y
add wave -radix unsigned sim:/bullet_collision_tb/target_x
add wave -radix unsigned sim:/bullet_collision_tb/target_y

# Bullet signals
add wave -divider {Bullet}
add wave sim:/bullet_collision_tb/bullet_active
add wave -radix unsigned sim:/bullet_collision_tb/bullet_x
add wave -radix unsigned sim:/bullet_collision_tb/bullet_y

# Collision signals
add wave -divider {Collision}
add wave sim:/bullet_collision_tb/coll
add wave sim:/bullet_collision_tb/hit_seen

# ------------------------------------------------------------
# Run long enough to see the intersection
# ------------------------------------------------------------
run 60 us

# ------------------------------------------------------------
# End of macro
# ------------------------------------------------------------
