##########################################################
# MAIN 50 MHz CLOCK (DE2 BOARD CLOCK)
##########################################################
create_clock -name CLK50 -period 20.0 [get_ports {clk_50}]


##########################################################
# VGA PIXEL CLOCK FROM PLL
# Change pll_inst if your instance has a different name
##########################################################
create_generated_clock \
    -name VGA_CLK \
    -source [get_ports clk_50] \
    [get_pins {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]


##########################################################
# LCD 400 Hz DIVIDED CLOCK
# (Generated inside de2lcd)
# Not performance-critical, but define it anyway
##########################################################
create_generated_clock \
    -name CLK400 \
    -source [get_ports clk_50] \
    -divide_by 125000 \
    [get_registers {*|CLK_400HZ}]


##########################################################
# PS/2 INPUTS ARE ASYNCHRONOUS → IGNORE TIMING
##########################################################
set_false_path -from [get_ports {ps2_clk}]
set_false_path -from [get_ports {ps2_data}]


##########################################################
# LCD BUS IS VERY SLOW. IGNORE TIMING.
##########################################################
set_false_path -to   [get_ports {DATA_BUS[*]}]
set_false_path -from [get_ports {DATA_BUS[*]}]
set_false_path -from [get_registers {*|DATA_BUS_VALUE}]
set_false_path -to   [get_registers {*|DATA_BUS_VALUE}]


##########################################################
# DISABLE TIMING CHECKS ON RESET (ASYNC)
##########################################################
# Adjust 'reset' to 'global_reset' or your actual port name
set_false_path -from [get_ports {reset}]


##########################################################
# GENERIC I/O DELAYS SO THERE ARE NO UNCONSTRAINED PATHS
##########################################################
# Constrain all non-clock inputs relative to CLK50
# (0 ns is fine; this is just to mark them as "timed")
set_input_delay 0.0 -clock CLK50 \
    [remove_from_collection [all_inputs] [get_ports {clk_50}]]

# Constrain all outputs relative to CLK50
set_output_delay 0.0 -clock CLK50 [all_outputs]

##########################################################
# REMOVE FALSE CLOCK DOMAINS FOUND BY TIMEQUEST
##########################################################

# LCD 400 Hz division is not a real clock domain
set_false_path -to   [get_registers *CLK_400HZ*]
set_false_path -from [get_registers *CLK_400HZ*]

# PS/2 internal filtered signals (not real clocks)
set_false_path -from [get_registers *keyboard_clk_filtered*]
set_false_path -from [get_registers *ready_set*]
set_false_path -from [get_registers *scan_int*]

# VGA counters mistaken as clocks
set_false_path -from [get_registers *sync_cnt*]