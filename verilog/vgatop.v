module vgatop(
    i_vgaclk,
    i_reset,

    i_enable,

    o_hSync,
    o_vSync,
    o_red,
    o_green,
    o_blue,

    o_inth,
    o_intv,

    o_pixGate, // high when in visible area
    i_pixData, // pixel data

    // wishbone for conf. reg access
    o_wb_ack,
    o_wb_dat,
    i_wb_dat,
    i_wb_addr,
    i_wb_sel,
    i_wb_clk,
    i_wb_we
);

input i_vgaclk;
input i_reset;
input i_enable;

output o_hSync;
output o_vSync;
output [2:0] o_red;
output [2:0] o_green;
output [1:0] o_blue;

output o_inth;
output o_intv;

input [7:0] i_pixData;
output [23:0] o_pixIdx;
output o_pixGate;

output o_wb_ack;
output [15:0] o_wb_dat;
/* verilator lint_off UNUSED */
input [15:0] i_wb_dat;
/* verilator lint_on UNUSED */
input [3:0] i_wb_addr;
input [1:0] i_wb_sel;
input i_wb_clk;
input i_wb_we;

assign o_red = i_pixData[2:0];
assign o_green = i_pixData[5:3];
assign o_blue = i_pixData[7:6];

reg [10:0] registers[0:8];

wire visible;
wire hSync;
wire vSync;

assign o_hSync = hSync ? registers[8][0] : ~registers[8][0];
assign o_vSync = vSync ? registers[8][1] : ~registers[8][1];

assign o_pixGate = visible;

// Register Map:
// 0: hSyncStart( registers[0] ),
// 1: hBpStart( registers[1] ),
// 2: hVisibleStart( registers[2] ),
// 3: hEnd( registers[3] ),
// 4: vSyncStart( registers[4] ),
// 5: vBpStart( registers[5] ),
// 6: vVisibleStart( registers[6] ),
// 7: vEnd( registers[7] ),
// 8: Bit 0 hSyncPolarity
//    Bit 1 vSyncPolarity

vgatiming timing_generator(
    .i_clk(i_vgaclk),
    .i_reset(i_enable && i_reset),

    .i_hSyncStart( registers[0] ),
    .i_hBpStart( registers[1] ),
    .i_hVisibleStart( registers[2] ),
    .i_hEnd( registers[3] ),

    .i_vSyncStart( registers[4] ),
    .i_vBpStart( registers[5] ),
    .i_vVisibleStart( registers[6] ),
    .i_vEnd( registers[7] ),

    .o_visible(visible),

    .o_hSync(hSync),
    .o_vSync(vSync),

    .o_inth(o_inth),
    .o_intv(o_intv)
);


//-----------------------------------------------------
// Wishbone register interface

wire valid_addr = (i_wb_addr < 9);
assign o_wb_dat = { 5'd0, registers[i_wb_addr] };
assign o_wb_ack = (i_wb_sel[1] || i_wb_sel[0]) && valid_addr;

always @(posedge i_wb_clk)
begin
    if( i_wb_we && valid_addr ) begin
        if( i_wb_sel[1] ) registers[i_wb_addr][10:8] <= i_wb_dat[10:8];
        if( i_wb_sel[0] ) registers[i_wb_addr][7:0] <= i_wb_dat[7:0];
    end
end

endmodule

