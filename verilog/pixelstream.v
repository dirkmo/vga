module pixelstream(
    i_clk,
    i_reset,

    i_pixAddr,
    i_pixClk,
    i_pixGate,
    o_pixDat,

    o_wb_addr,
    o_wb_sel,
    o_wb_cyc,
    i_wb_ack,
    i_wb_dat
);

input i_clk;
input i_reset;

input [31:0] i_pixAddr;
input i_pixClk;
input i_pixGate;
output [7:0] o_pixDat;

output [31:0] o_wb_addr;
output [3:0] o_wb_sel;
output o_wb_cyc;
input i_wb_ack;
input [31:0] i_wb_dat;


wire fifo0_empty;
wire fifo0_half;
wire fifo0_full;

reg fifo0_push;
reg fifo0_pop;
wire [31:0] fifo0_dat;

fifo #(.WIDTH(32), .DEPTH(4)) fifo0(
    .i_clk(i_clk),
    .i_reset(i_reset),

    .o_empty(fifo0_empty),
    .o_half(fifo0_half),
    .o_full(fifo0_full),

    .i_dat(i_wb_dat),
    .o_dat(fifo0_dat),

    .i_push(fifo0_push),
    .i_pop(fifo0_pop)
);

always @(posedge i_pixClk)
begin
    if( fifo0_half ) begin

    end
end


endmodule

