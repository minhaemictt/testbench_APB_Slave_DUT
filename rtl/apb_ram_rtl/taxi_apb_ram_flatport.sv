`resetall
`timescale 1ns / 1ps
`default_nettype none


module taxi_apb_ram_flatport #(
    parameter ADDR_WIDTH = 11
)
(
    input  wire logic                  clk,
    input  wire logic                  rst,


    input  wire logic [31:0]           s_apb_paddr,
    input  wire logic [2:0]            s_apb_pprot,
    input  wire logic                  s_apb_psel,
    input  wire logic                  s_apb_penable,
    input  wire logic                  s_apb_pwrite,
    input  wire logic [31:0]           s_apb_pwdata,
    input  wire logic [3:0]            s_apb_pstrb,
    output      logic                  s_apb_pready,
    output      logic [31:0]           s_apb_prdata,
    output      logic                  s_apb_pslverr,
    input  wire logic [0:0]            s_apb_pauser,
    input  wire logic [0:0]            s_apb_pwuser,
    output      logic [0:0]            s_apb_pruser,
    output      logic [0:0]            s_apb_pbuser
);

if (8 * 4 != 32)
    $fatal(0, "Error: APB data width not evenly divisible (instance %m)");

if (2**2 != 4)
    $fatal(0, "Error: APB byte lane count must be even power of two (instance %m)");

logic s_apb_pready_reg = 1'b0, s_apb_pready_next;
logic s_apb_pready_pipe_reg = 1'b0;

wire [ADDR_WIDTH-3:0] s_apb_paddr_valid = s_apb_paddr[ADDR_WIDTH-1:2];

// Address validity: in range when paddr < 2^ADDR_WIDTH
wire addr_in_range = (s_apb_paddr < (1 << ADDR_WIDTH));

assign s_apb_pready = s_apb_pready_reg;
assign s_apb_pslverr = ~addr_in_range;
assign s_apb_pruser = '0;
assign s_apb_pbuser = '0;

always_comb begin
    s_apb_pready_next = 1'b0;
    if (s_apb_psel && (!s_apb_pready_reg && !s_apb_pready_pipe_reg)) begin
        s_apb_pready_next = 1'b1;
    end
end

wire csb0 = ~(s_apb_psel && !s_apb_pready_reg && !s_apb_pready_pipe_reg && addr_in_range);
wire web0 = ~s_apb_pwrite;
wire [3:0] wmask0 = s_apb_pstrb;
wire [31:0] dout0;

// OpenRAM Macro Instantiation
sky130_sram_2kbyte_1rw1r_32x512_8 sram_inst (
    .clk0   (clk),
    .csb0   (csb0),
    .web0   (web0),
    .wmask0 (wmask0),
    .addr0  (s_apb_paddr_valid),
    .din0   (s_apb_pwdata),
    .dout0  (dout0),
    
    // Tie off unused read-only Port 1
    .clk1   (1'b0),
    .csb1   (1'b1),
    .addr1  (9'b0),
    .dout1  ()
);

assign s_apb_prdata = dout0;

always @(posedge clk) begin
    s_apb_pready_reg <= s_apb_pready_next;
    s_apb_pready_pipe_reg <= s_apb_pready_reg;
    if (rst) begin
        s_apb_pready_reg <= 1'b0;
    end
end

endmodule
`resetall
