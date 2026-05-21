// Behavioral replacement for Gowin FIFO_SC_HS_Top IP
// Parameters matching fifo_sc_hs.ipc: WIDTH_W=8, DEPTH_W=6, FWFT=false, OUTPUT_REG=false
// Replaces the encrypted fifo_sc_hs.vhd which fails with gw2a.components VDB version mismatch.

module FIFO_SC_HS_Top (
    input  [7:0] Data,
    input        Clk,
    input        WrEn,
    input        RdEn,
    input        Reset,
    output reg [7:0] Q,
    output       Empty,
    output       Full
);

localparam DEPTH  = 64;   // 2^DEPTH_W = 2^6
localparam AW     = 6;    // address width

reg [7:0] mem [0:DEPTH-1];
reg [AW:0] wr_ptr;
reg [AW:0] rd_ptr;

wire [AW-1:0] wr_addr = wr_ptr[AW-1:0];
wire [AW-1:0] rd_addr = rd_ptr[AW-1:0];
wire [AW:0]   count   = wr_ptr - rd_ptr;

assign Empty = (count == 0);
assign Full  = (count == DEPTH);

always @(posedge Clk) begin
    if (Reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        Q      <= 8'h00;
    end else begin
        if (WrEn && !Full) begin
            mem[wr_addr] <= Data;
            wr_ptr <= wr_ptr + 1;
        end
        if (RdEn && !Empty) begin
            Q      <= mem[rd_addr];
            rd_ptr <= rd_ptr + 1;
        end
    end
end

endmodule
