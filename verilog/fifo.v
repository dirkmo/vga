module fifo(
    i_clk,
	i_reset,
    i_dat,
    o_dat,
    i_push,
    i_pop,
	o_empty,
    o_half, // 1 if less than half full
	o_full
);

parameter
    WIDTH = 32, // word size
    DEPTH = 4; // log2 of fifo depth

input i_clk;
input i_reset;
input  [WIDTH-1:0] i_dat;
output [WIDTH-1:0] o_dat;
input i_push;
input i_pop;
output o_empty;
output o_half;
output o_full;

reg [WIDTH-1:0] buffer[2**DEPTH-1:0];
reg [DEPTH-1:0] rd_idx;
reg [DEPTH-1:0] wr_idx;
reg [DEPTH:0] r_count; // has to be one bit wider for count of full fifo

assign o_empty = ~|r_count;
assign o_half = ~|r_count[DEPTH:DEPTH-1];
assign o_full = r_count[DEPTH];
assign o_dat = buffer[rd_idx];

wire [DEPTH-1:0] rd_idx_next = rd_idx + 'd1;
wire [DEPTH-1:0] wr_idx_next = wr_idx + 'd1;


// push,pop edge detection
reg r_push, r_pop;
wire push_pe = ~r_push && i_push;
wire pop_pe = ~r_pop && i_pop;

always @(posedge i_clk) begin
    r_push <= i_push;
    r_pop <= i_pop;
end

// fifo control

always @(posedge i_clk) begin
    if( push_pe && ~o_full ) begin
        wr_idx <= wr_idx_next;
        buffer[wr_idx] <= i_dat;
        r_count <= r_count + 'b1;
    end else if( pop_pe && ~o_empty ) begin
        rd_idx <= rd_idx_next;
        r_count <= r_count - 'b1;
    end
    if( i_reset ) begin
        rd_idx <= 'd0;
        wr_idx <= 'd0;
        r_count <= 'd0;
    end
end

endmodule
