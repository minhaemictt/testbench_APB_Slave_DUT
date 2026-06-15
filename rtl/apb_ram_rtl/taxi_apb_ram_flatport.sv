// SPDX-License-Identifier: CERN-OHL-S-2.0
/*

Copyright (c) 2025 FPGA Ninja, LLC

Authors:
- Alex Forencich

Flatport adaptation for OpenLane compatibility.

*/

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * APB RAM (Flatport version — no modport, no interface)
 */
module taxi_apb_ram_flatport #
(
    // Width of data bus in bits
    parameter DATA_W = 32,
    // Width of address bus in bits
    parameter ADDR_W = 16,
    // Width of APB address bus in bits
    parameter APB_ADDR_W = 32,
    // Width of pstrb (width of data bus in bytes)
    parameter STRB_W = (DATA_W/8),
    // Extra pipeline register on output
    parameter logic PIPELINE_OUTPUT = 1'b0,
    // Width of pauser signal
    parameter PAUSER_W = 1,
    // Width of pwuser signal
    parameter PWUSER_W = 1,
    // Width of pruser signal
    parameter PRUSER_W = 1,
    // Width of pbuser signal
    parameter PBUSER_W = 1
)
(
    input  wire logic                  clk,
    input  wire logic                  rst,

    /*
     * APB slave interface (flat ports)
     */
    input  wire logic [APB_ADDR_W-1:0] s_apb_paddr,
    input  wire logic [2:0]            s_apb_pprot,
    input  wire logic                  s_apb_psel,
    input  wire logic                  s_apb_penable,
    input  wire logic                  s_apb_pwrite,
    input  wire logic [DATA_W-1:0]     s_apb_pwdata,
    input  wire logic [STRB_W-1:0]     s_apb_pstrb,
    output      logic                  s_apb_pready,
    output      logic [DATA_W-1:0]     s_apb_prdata,
    output      logic                  s_apb_pslverr,
    input  wire logic [PAUSER_W-1:0]   s_apb_pauser,
    input  wire logic [PWUSER_W-1:0]   s_apb_pwuser,
    output      logic [PRUSER_W-1:0]   s_apb_pruser,
    output      logic [PBUSER_W-1:0]   s_apb_pbuser
);

localparam VALID_ADDR_W = ADDR_W - $clog2(STRB_W);
localparam BYTE_LANES = STRB_W;
localparam BYTE_W = DATA_W/BYTE_LANES;

// check configuration
if (BYTE_W * STRB_W != DATA_W)
    $fatal(0, "Error: APB data width not evenly divisible (instance %m)");

if (2**$clog2(BYTE_LANES) != BYTE_LANES)
    $fatal(0, "Error: APB byte lane count must be even power of two (instance %m)");

logic mem_wr_en;
logic mem_rd_en;

logic s_apb_pready_reg = 1'b0, s_apb_pready_next;
logic s_apb_pready_pipe_reg = 1'b0;
logic [DATA_W-1:0] s_apb_prdata_reg = '0, s_apb_prdata_next;
logic [DATA_W-1:0] s_apb_prdata_pipe_reg = '0;

// (* RAM_STYLE="BLOCK" *)
logic [DATA_W-1:0] mem[2**VALID_ADDR_W];

integer i;
initial begin
    for (i = 0; i < 2**VALID_ADDR_W; i = i + 1) begin
        mem[i] = '0;
    end
end

wire [VALID_ADDR_W-1:0] s_apb_paddr_valid = VALID_ADDR_W'(s_apb_paddr >> $clog2(STRB_W));

assign s_apb_prdata = PIPELINE_OUTPUT ? s_apb_prdata_pipe_reg : s_apb_prdata_reg;
assign s_apb_pready = PIPELINE_OUTPUT ? s_apb_pready_pipe_reg : s_apb_pready_reg;
assign s_apb_pslverr = 1'b0;
assign s_apb_pruser = '0;
assign s_apb_pbuser = '0;

always_comb begin
    mem_wr_en = 1'b0;
    mem_rd_en = 1'b0;

    s_apb_pready_next = 1'b0;

    if (s_apb_psel && (!s_apb_pready_reg && (PIPELINE_OUTPUT || !s_apb_pready_pipe_reg))) begin
        s_apb_pready_next = 1'b1;

        if (s_apb_pwrite) begin
            mem_wr_en = 1'b1;
        end else begin
            mem_rd_en = 1'b1;
        end
    end
end

always @(posedge clk) begin
    s_apb_pready_reg <= s_apb_pready_next;

    for (integer i = 0; i < BYTE_LANES; i = i + 1) begin
        if (mem_wr_en && s_apb_pstrb[i]) begin
            mem[s_apb_paddr_valid][BYTE_W*i +: BYTE_W] <= s_apb_pwdata[BYTE_W*i +: BYTE_W];
        end
    end

    if (mem_rd_en) begin
        s_apb_prdata_reg <= mem[s_apb_paddr_valid];
    end

    s_apb_prdata_pipe_reg <= s_apb_prdata_reg;
    s_apb_pready_pipe_reg <= s_apb_pready_reg;

    if (rst) begin
        s_apb_pready_reg <= 1'b0;
    end
end

endmodule

`resetall
