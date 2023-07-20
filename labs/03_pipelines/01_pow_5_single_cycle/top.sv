`include "config.svh"

`ifndef SIMULATION

module top
# (
    parameter clk_mhz = 50,
              w_key   = 4,
              w_sw    = 8,
              w_led   = 8,
              w_digit = 8,
              w_gpio  = 20
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // VGA

    output logic                 vsync,
    output logic                 hsync,
    output logic [          3:0] red,
    output logic [          3:0] green,
    output logic [          3:0] blue,

    input        [         23:0] mic,

    // General-purpose Input/Output

    inout  logic [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

    // assign led      = '0;
    // assign abcdefgh = '0;
    // assign digit    = '0;
       assign vsync    = '0;
       assign hsync    = '0;
       assign red      = '0;
       assign green    = '0;
       assign blue     = '0;

    //------------------------------------------------------------------------

    localparam width = 12;

    // Upstream

    wire               up_vld = key [1];
    wire [width - 1:0] up_data;

    // Downstream - no flow control

    wire               down_vld;
    wire [width - 1:0] down_data;

    //------------------------------------------------------------------------

    localparam max_cnt   = 5,
               cnt_width = $clog2 (max_cnt);

    logic [cnt_width - 1:0] cnt;

    always_ff @ (posedge slow_clk or posedge rst)
      if (rst)
        cnt <= '0;
      else if (up_vld)
        cnt <= (cnt == max_cnt ? '0 : cnt + 1'd1);

    assign up_data = width' (cnt);

    //------------------------------------------------------------------------

    pow_5_single_cycle
    # (.width (width))
    pow_5 (.clk (slow_clk), .*);

    //------------------------------------------------------------------------

    wire [7:0] abcdefgh_pre;

    localparam w_seg_number = 4 * w_digit;

    seven_segment_display # (w_digit) i_display
    (
      .clk      (clk),
      .number   (w_seg_number' ({ up_data [3:0], down_data [11:0] })),
      .dots     ('0),
      .abcdefgh (abcdefgh_pre),
      .digit    (digit),
      .*
    );

    localparam sign_nothing = 8'b0000_0000;

    assign abcdefgh =
         (digit & 4'b1111) == 4'b0000
      | ((digit &  3'b111) != 3'b000 & ~ down_vld)
          ? sign_nothing : abcdefgh_pre;

    assign led = w_led' ({ slow_clk, up_vld, 1'b0, down_vld, 1'b0 });

endmodule

`endif
