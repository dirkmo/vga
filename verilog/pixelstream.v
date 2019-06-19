module pixelstream(
    i_wb_clk,
    i_wb_rst,

    i_pixAddrBase,
    i_pixAddrReset,
    i_pixClk,
    i_pixGate, // only shift out pixels when gate is 1
    o_pixDat,

    o_wb_addr,
    o_wb_cyc,
    i_wb_ack,
    i_wb_dat
);

input [31:0] i_pixAddrBase;
input i_pixAddrReset;
input i_pixClk;
input i_pixGate;
output [7:0] o_pixDat;

input i_wb_clk;
input i_wb_rst;
input i_wb_reset;
output [31:0] o_wb_addr;
output o_wb_cyc;
input i_wb_ack;
input [31:0] i_wb_dat;

//--------------------------------------
// fifo

wire fifo0_empty;
wire fifo0_half;
wire fifo0_full;

wire fifo0_push;
wire fifo0_pop;
wire [31:0] fifo0_dat;

fifo #(.WIDTH(32), .DEPTH(4)) fifo0(
    .i_clk(i_wb_clk),
    .i_reset(i_wb_rst),

    .o_empty(fifo0_empty),
    .o_half(fifo0_half),
    .o_full(fifo0_full),

    .i_dat(i_wb_dat),
    .o_dat(fifo0_dat),

    .i_push(fifo0_push),
    .i_pop(fifo0_pop)
);

// start to fill up fifo when half full
reg r_fillup;
always @(posedge i_pixClk)
begin
    if( fifo0_full ) begin
        r_fillup <= 0;
    end
    if( fifo0_half ) begin
        r_fillup <= 1;
    end
end

//-------------------------------
// fifo gives 32 bit data
// shifting out byte wise

reg [1:0] r_idx;
always @(posedge i_pixClk)
begin
    if( i_pixGate ) begin
        r_idx <= r_idx + 'd1;
    end
    if( i_pixAddrReset ) begin
        r_idx <= 0;
    end
end

assign fifo0_pop = r_idx == 'd3;

assign o_pixDat = r_idx == 0 ? fifo0_dat[31:24] :
                  r_idx == 1 ? fifo0_dat[23:16] :
                  r_idx == 2 ? fifo0_dat[15:8]  : fifo0_dat[7:0];


//--------------------------------------
// reduced wishbone interface

reg [31:0] r_addr;

assign o_wb_addr = r_addr;
assign o_wb_cyc = r_fillup;
assign fifo0_push = i_wb_ack;

always @(posedge i_wb_clk)
begin
    if( i_wb_ack ) begin
        
    end
end



always @(posedge i_wb_clk)
begin
    if( fifo0_push ) begin
        r_addr <= r_addr + 'd4;
    end
    if( i_pixAddrReset ) begin
        r_addr <= i_pixAddrBase;
    end
end

endmodule

