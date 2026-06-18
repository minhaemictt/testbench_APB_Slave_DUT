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

// OpenRAM SRAM model
// Words: 512
// Word size: 32
// Write size: 8

(* blackbox *)
module sky130_sram_2kbyte_1rw1r_32x512_8(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Port 0: RW
    clk0,csb0,web0,wmask0,addr0,din0,dout0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );

  parameter NUM_WMASKS = 4 ;
  parameter DATA_WIDTH = 32 ;
  parameter ADDR_WIDTH = 9 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  // FIXME: This delay is arbitrary.
  parameter DELAY = 3 ;
  parameter VERBOSE = 1 ; //Set to 0 to only display warnings
  parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input  clk0; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [NUM_WMASKS-1:0]   wmask0; // write mask
  input [ADDR_WIDTH-1:0]  addr0;
  input [DATA_WIDTH-1:0]  din0;
  output [DATA_WIDTH-1:0] dout0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [ADDR_WIDTH-1:0]  addr1;
  output [DATA_WIDTH-1:0] dout1;

`ifndef SYNTHESIS
  reg  csb0_reg;
  reg  web0_reg;
  reg [NUM_WMASKS-1:0]   wmask0_reg;
  reg [ADDR_WIDTH-1:0]  addr0_reg;
  reg [DATA_WIDTH-1:0]  din0_reg;
  reg [DATA_WIDTH-1:0]  dout0;

  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    web0_reg = web0;
    wmask0_reg = wmask0;
    addr0_reg = addr0;
    din0_reg = din0;
    #(T_HOLD) dout0 = 32'bx;
    if ( !csb0_reg && web0_reg && VERBOSE ) 
      $display($time," Reading %m addr0=%b dout0=%b",addr0_reg,mem[addr0_reg]);
    if ( !csb0_reg && !web0_reg && VERBOSE )
      $display($time," Writing %m addr0=%b din0=%b wmask0=%b",addr0_reg,din0_reg,wmask0_reg);
  end

  reg  csb1_reg;
  reg [ADDR_WIDTH-1:0]  addr1_reg;
  reg [DATA_WIDTH-1:0]  dout1;

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
    if (!csb0 && !web0 && !csb1 && (addr0 == addr1))
         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
    #(T_HOLD) dout1 = 32'bx;
    if ( !csb1_reg && VERBOSE ) 
      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
  end

reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];

  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if ( !csb0_reg && !web0_reg ) begin
        if (wmask0_reg[0])
                mem[addr0_reg][7:0] = din0_reg[7:0];
        if (wmask0_reg[1])
                mem[addr0_reg][15:8] = din0_reg[15:8];
        if (wmask0_reg[2])
                mem[addr0_reg][23:16] = din0_reg[23:16];
        if (wmask0_reg[3])
                mem[addr0_reg][31:24] = din0_reg[31:24];
    end
  end

  // Memory Read Block Port 0
  // Read Operation : When web0 = 1, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_READ0
    if (!csb0_reg && web0_reg)
       dout0 <= #(DELAY) mem[addr0_reg];
  end

  // Memory Read Block Port 1
  // Read Operation : When web1 = 1, csb1 = 0
  always @ (negedge clk1)
  begin : MEM_READ1
    if (!csb1_reg)
       dout1 <= #(DELAY) mem[addr1_reg];
  end
`endif

endmodule
