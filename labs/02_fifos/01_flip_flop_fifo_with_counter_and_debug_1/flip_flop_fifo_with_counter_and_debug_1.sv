`include "config.svh"

`define DEBUG

module flip_flop_fifo_with_counter_and_debug_1
# (
    parameter width = 8, depth = 10
)
(
    input                clk,
    input                rst,
    input                push,
    input                pop,
    input  [width - 1:0] write_data,
    output [width - 1:0] read_data,
    output               empty,
    output               full

    `ifdef DEBUG
    ,
    output       [depth - 1:0]              debug_valid,
    output logic [depth - 1:0][width - 1:0] debug_data

    `endif
);

    //------------------------------------------------------------------------

    localparam pointer_width = $clog2 (depth),
               counter_width = $clog2 (depth + 1);

    localparam [counter_width - 1:0] max_ptr = counter_width' (depth - 1);

    //------------------------------------------------------------------------

    logic [pointer_width - 1:0] wr_ptr, rd_ptr;
    logic [counter_width - 1:0] cnt;

    logic [width - 1:0] data [0: depth - 1];

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            wr_ptr <= '0;
        else if (push)
            wr_ptr <= wr_ptr == max_ptr ? '0 : wr_ptr + 1'b1;

    // TODO: Add logic for rd_ptr

    //------------------------------------------------------------------------

    always_ff @ (posedge clk)
        if (push)
            data [wr_ptr] <= write_data;

    assign read_data = data [rd_ptr];

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            cnt <= '0;
        else if (push & ~ pop)
            cnt <= cnt + 1'b1;
        else if (pop & ~ push)
            cnt <= cnt - 1'b1;

    //------------------------------------------------------------------------

    assign empty = (cnt == '0);  // Same as "~| cnt"

    // TODO: Add logic for full output

    //------------------------------------------------------------------------

    `ifdef DEBUG

    assign debug_valid = { depth { 1'b1 } } >> (depth - cnt);

    always_comb
        for (int i = 0; i < depth; i ++)
            if (rd_ptr + i < depth)
                debug_data [i] = data [rd_ptr + i];
            else
                debug_data [i] = data [rd_ptr + i - depth];

    `endif

endmodule
