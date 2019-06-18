module vgatiming(
    i_clk,
    i_reset,

    i_hSyncStart,
    i_hBpStart,
    i_hVisibleStart,
    i_hEnd,

    i_vSyncStart,
    i_vBpStart,
    i_vVisibleStart,
    i_vEnd,

    o_visible,

    o_hSync,
    o_vSync,

    o_inth,
    o_intv
);

input i_clk;
input i_reset;

input [10:0] i_hSyncStart;
input [10:0] i_hBpStart;
input [10:0] i_hVisibleStart;
input [10:0] i_hEnd;

input [10:0] i_vSyncStart;
input [10:0] i_vBpStart;
input [10:0] i_vVisibleStart;
input [10:0] i_vEnd;

output o_visible;
output o_hSync;
output o_vSync;

output o_inth;
output o_intv;

reg [10:0] r_hcounter;
reg [10:0] r_vcounter;
reg r_hSync;
reg r_vSync;

wire hFpStart      = r_hcounter == 0;
wire hSyncStart    = r_hcounter == i_hSyncStart;
wire hBpStart      = r_hcounter == i_hBpStart;
wire hVisibleStart = r_hcounter == i_hVisibleStart;
wire hEnd          = r_hcounter == i_hEnd;

wire vFpStart      = r_vcounter == 0;
wire vSyncStart    = r_vcounter == i_vSyncStart;
wire vBpStart      = r_vcounter == i_vBpStart;
wire vVisibleStart = r_vcounter == i_vVisibleStart;
wire vEnd          = r_vcounter == i_vEnd;

assign o_inth = hFpStart;
assign o_intv = vFpStart;
assign o_hSync = r_hSync;
assign o_vSync = r_vSync;

reg r_hVisible;
reg r_vVisible;

assign o_visible = r_hVisible && r_vVisible;

always @(posedge i_clk)
begin
    r_hcounter <= r_hcounter + 1;
    if( i_reset || hEnd ) begin
        r_hcounter <= 0;
    end
end

always @(posedge i_clk)
begin
    if( hEnd ) begin
        r_vcounter <= r_vcounter + 1;
    end
    if( i_reset || vEnd ) begin
        r_vcounter <= 0;
    end
end

always @(posedge i_clk)
begin
    if( hSyncStart ) begin
        r_hSync <= 1;
    end
    if( i_reset || hBpStart ) begin
        r_hSync <= 0;
    end
end

always @(posedge i_clk)
begin
    if( vSyncStart ) begin
        r_vSync <= 1;
    end
    if( i_reset || vBpStart ) begin
        r_vSync <= 0;
    end
end

always @(posedge i_clk)
begin
    if( hVisibleStart ) begin
        r_hVisible <= 1;
    end
    if( i_reset || hEnd ) begin
        r_hVisible <= 0;
    end
end

always @(posedge i_clk)
begin
    if( vVisibleStart ) begin
        r_vVisible <= 1;
    end
    if( i_reset || vEnd ) begin
        r_vVisible <= 0;
    end
end

endmodule

