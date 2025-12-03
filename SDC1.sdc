create_clock -name CLK50 -period 20.000 [get_ports {clk_50}]


create_generated_clock \
    -name CLK100 \
    -source [get_clocks CLK50] \
    -multiply_by 2 \
    [get_pins {pll_inst|altpll_component|auto_generated|pll1|clk[0]}]


create_generated_clock \
    -name LCD_400HZ \
    -source [get_clocks CLK50] \
    -divide_by 125000 \
    [get_registers {*|CLK_400HZ}]


# PS/2 is asynchronous and slow
set_false_path -from [get_ports {ps2_clk}]
set_false_path -from [get_ports {ps2_data}]

# Filtered PS/2 internal clock (name from reports)
set_false_path -from [get_registers *keyboard_clk_filtered*]

# LCD data bus is super slow compared to system clocks
set_false_path -to   [get_ports {DATA_BUS[*]}]
set_false_path -from [get_ports {DATA_BUS[*]}]

# Asynchronous resets (global + LCD)
set_false_path -from [get_ports *reset*]
