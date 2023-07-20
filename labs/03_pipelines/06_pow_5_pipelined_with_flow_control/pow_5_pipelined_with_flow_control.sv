`include "config.svh"

module pow_5_pipelined_with_flow_control
# (
  parameter width = 0
)
(
  input                clk,
  input                rst,

  input                up_vld,    // upstream
  output               up_rdy,
  input  [width - 1:0] up_data,

  output               down_vld,  // downstream
  input                down_rdy,
  output [width - 1:0] down_data
);

  // TODO: Implement the module based on
  //
  // ../03_pipelines/04_pow_5_pipelined_without_flow_control
  //   /pow_5_pipelined_without_flow_control.sv
  //
  // with additional flow control using the signals up_rdy and down_rdy.

endmodule
