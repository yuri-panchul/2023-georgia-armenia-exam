// Asynchronous reset here is needed for some FPGA boards we use

`include "config.svh"

module board_specific_top
# (
    parameter clk_mhz = 50,
              w_key   = 4,
              w_sw    = 10,
              w_led   = 10,
              w_digit = 6,
              w_gpio  = 72
)
(
    input                CLOCK_50,
    input                RESET_N,

    input  [w_key - 1:0] KEY,
    input  [w_sw  - 1:0] SW,
    output [w_led - 1:0] LEDR,

    output [        6:0] HEX0,
    output [        6:0] HEX1,
    output [        6:0] HEX2,
    output [        6:0] HEX3,
    output [        6:0] HEX4,
    output [        6:0] HEX5,

    output               VGA_HS,
    output               VGA_VS,
    output [        3:0] VGA_R,
    output [        3:0] VGA_G,
    output [        3:0] VGA_B,

    inout  [       35:0] GPIO_0,
    inout  [       35:0] GPIO_1
);

    //------------------------------------------------------------------------

    wire clk = CLOCK_50;
    wire rst = ~ RESET_N;

    //------------------------------------------------------------------------

    wire slow_clk_raw, slow_clk;

    slow_clk_gen # (.fast_clk_mhz (clk_mhz), .slow_clk_hz (`SLOW_CLK_HZ))
    i_slow_clk_gen (.slow_clk_raw (slow_clk_raw), .*);

    // "global" is Intel FPGA-specific primitive to route
    // a signal coming from data into clock tree

    global i_global (.in (slow_clk_raw), .out (slow_clk));

    //------------------------------------------------------------------------

    wire [          7:0] abcdefgh;
    wire [w_digit - 1:0] digit;

    wire [         23:0] mic;

    //------------------------------------------------------------------------

    top
    # (
        .clk_mhz ( clk_mhz ),
        .w_key   ( w_key   ),
        .w_sw    ( w_sw    ),
        .w_led   ( w_led   ),
        .w_digit ( w_digit ),
        .w_gpio  ( w_gpio  )
    )
    i_top
    (
        .clk      (   clk                ),
        .slow_clk (   slow_clk           ),
        .rst      (   rst                ),

        .key      ( ~ KEY                ),
        .sw       (   SW                 ),

        .led      (   LEDR               ),

        .abcdefgh (   abcdefgh           ),
        .digit    (   digit              ),

        .vsync    (   VGA_VS             ),
        .hsync    (   VGA_HS             ),

        .red      (   VGA_R              ),
        .green    (   VGA_G              ),
        .blue     (   VGA_B              ),

        .mic      (   mic                ),
        .gpio     (   { GPIO_1, GPIO_0 } )
    );

    //------------------------------------------------------------------------

    wire [$left (abcdefgh):0] hgfedcba;

    generate
        genvar i;

        for (i = 0; i < $bits (abcdefgh); i ++)
        begin : abc
            assign hgfedcba [i] = abcdefgh [$left (abcdefgh) - i];
        end
    endgenerate

    assign HEX0 = digit [0] ? ~ hgfedcba [$left (HEX0):0] : '1;
    assign HEX1 = digit [1] ? ~ hgfedcba [$left (HEX1):0] : '1;
    assign HEX2 = digit [2] ? ~ hgfedcba [$left (HEX2):0] : '1;
    assign HEX3 = digit [3] ? ~ hgfedcba [$left (HEX3):0] : '1;
    assign HEX4 = digit [4] ? ~ hgfedcba [$left (HEX4):0] : '1;
    assign HEX5 = digit [5] ? ~ hgfedcba [$left (HEX5):0] : '1;

    //------------------------------------------------------------------------

    inmp441_mic_i2s_receiver i_microphone
    (
        .clk   ( clk        ),
        .rst   ( rst        ),
        .lr    ( GPIO_0 [5] ),
        .ws    ( GPIO_0 [3] ),
        .sck   ( GPIO_0 [1] ),
        .sd    ( GPIO_0 [0] ),
        .value ( mic        )
    );

    assign GPIO_0 [4] = 1'b0;  // GND
    assign GPIO_0 [2] = 1'b1;  // VCC

endmodule
