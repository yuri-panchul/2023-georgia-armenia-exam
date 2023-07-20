`include "config.svh"

module pow_5_single_cycle
# (
  parameter width = 0
)
(
  input                clk,
  input                rst,

  input                up_vld,
  input  [width - 1:0] up_data,

  output               down_vld,
  output [width - 1:0] down_data
);

  wire vld_1;
  wire [width - 1:0] arg_1;

  reg_without_flow_control # (.w (width)) r0
  (
    .up_vld    ( up_vld  ),
    .up_data   ( up_data ),

    .down_vld  ( vld_1   ),
    .down_data ( arg_1   ),

    .*
  );

  wire [width - 1:0] mul_1 = arg_1 * arg_1 * arg_1 * arg_1 * arg_1;

  reg_without_flow_control # (.w (width)) r1
  (
    .up_vld    ( vld_1     ),
    .up_data   ( mul_1     ),

    .down_vld  ( down_vld  ),
    .down_data ( down_data ),

    .*
  );

endmodule
