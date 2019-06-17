module vgatop(
    i_vgaclk,
    i_reset,

    o_hSync,
    o_vSync,
    o_red,
    o_green,
    o_blue,

    o_inth,
    o_intv,

    o_pixIdx,
    i_pixData,

    // wishbone for conf. reg access
    i_wb_dat,
    o_wb_dat,
    i_wb_addr,
    i_wb_sel,
    i_wb_clk,
    i_wb_we
);

input i_vgaclk;
input i_reset;

output o_hSync;
output o_vSync;
output [2:0] o_red;
output [2:0] o_green;
output [1:0] o_blue;

output o_inth;
output o_intv;

input [7:0] i_pixData;
output [23:0] o_pixIdx;

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

wire pixclk;

vgatiming timing_generator(
    .i_clk(i_vgaclk),
    .i_reset(i_reset),

    .i_hSyncStart( registers[0] ),
    .i_hBpStart( registers[1] ),
    .i_hVisibleStart( registers[2] ),
    .i_hEnd( registers[3] ),
    .i_hSyncPol( registers[8][0] ),

    .i_vSyncStart( registers[4] ),
    .i_vBpStart( registers[5] ),
    .i_vVisibleStart( registers[6] ),
    .i_vEnd( registers[7] ),
    .i_vSyncPol( registers[8][1] ),

    .o_pixclk(pixclk),

    .o_hSync(o_hSync),
    .o_vSync(o_vSync),

    .o_inth(o_inth),
    .o_intv(o_intv)
);


reg [23:0] r_pixAddr;
assign o_pixIdx = r_pixAddr;

always @(posedge i_vgaclk)
begin
    if( pixclk ) begin
        r_pixAddr <= r_pixAddr + 24'd1;
    end
    if(i_reset || o_vSync) begin
        r_pixAddr <= 0;
    end
end

//-----------------------------------------------------
// Wishbone register interface

assign o_wb_dat = { 5'd0, registers[i_wb_addr] };

always @(posedge i_wb_clk)
begin
    if( i_wb_we && ( i_wb_addr < 9 ) ) begin
        if( i_wb_sel[1] ) registers[i_wb_addr][10:8] <= i_wb_dat[10:8];
        if( i_wb_sel[0] ) registers[i_wb_addr][7:0] <= i_wb_dat[7:0];
    end
end

endmodule

