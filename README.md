# Verification of an AMBA APB v3 SRAM using a UVM-Based Layered Testbench with SVA & Functional Coverage

This repository contains a comprehensive, industry-standard verification environment developed using the Universal Verification Methodology (UVM). The testbench verifies an AMBA v3 APB-compliant Synchronous RAM (SRAM) IP block using constrained-random stimulus, SystemVerilog Assertions (SVA) for protocol compliance, and a detailed Functional Coverage model.

---

## Project Scope & Contributions

* **Design Under Test (DUT):** The RTL code for the `apb_v3_sram` core was developed by Farshad under the MIT Open Source License. It implements an SRAM core with an AMBA 3 APB interface featuring parameterized address/data bus widths and memory sizes.
* **Verification Environment (My Core Contribution):** * Designed and implemented a modular UVM Testbench Architecture from scratch.  
  * Authored SystemVerilog Assertions (SVA) bound to the interface for real-time protocol violation checks.  
  * Built a Functional Coverage Model (`covergroup`) to track and ensure high-fidelity testing of bus phases, valid/invalid memory spaces, and error responses.

---

## Testbench Architecture & Directory Structure

The verification environment implements standard UVM components to ensure separation of concerns, scalability, and structural reusability. The repository is organized as follows:

```text
apb_slave_pbl_project/
├── src/
│   └── apb_slave_sample_RTL.v
├── tb/
│   ├── apb_master_uvm_agent.sv
│   ├── apb_master_uvm_driver.sv
│   ├── apb_master_uvm_environment.sv
│   ├── apb_master_uvm_interface.sv
│   ├── apb_master_uvm_monitor.sv
│   ├── apb_master_uvm_package.sv
│   ├── apb_master_uvm_scoreboard.sv
│   ├── apb_master_uvm_sequence.sv
│   ├── apb_master_uvm_sequencer.sv
│   ├── apb_master_uvm_test.sv
│   └── apb_master_uvm_top.sv
├── .gitignore
└── README.md
```

---

## Protocol Verification via SystemVerilog Assertions (SVA)

To guarantee exact compliance with the AMBA 3 APB protocol specifications, immediate concurrent assertions are embedded inside the `apb_master_uvm_interface`. These check critical timing relationships synchronously on the `posedge clk`:

### 1. Phase Transition
Ensures a `SETUP` phase (`PSEL=1`, `PENABLE=0`) is strictly followed by an `ACCESS` phase (`PSEL=1`, `PENABLE=1`) in the consecutive cycle.
```systemverilog
assert property (@(posedge clk) disable iff (prstn !== 1) SETUP |=> ACCESS) 
  else $error("SETUP not followed by ACCESS");
```

### 2. Signal Stability
Validates that during the `ACCESS` phase, the address (`paddr`) and write data (`pwdata`) remain perfectly stable while `pready` is high.
```systemverilog
assert property (@(posedge clk) disable iff (prstn !== 1) ACCESS |-> (pready == 1 && $stable(paddr) && $stable(pwdata))) 
  else $error("ACCESS phase: pready not high or signals not stable");
```

### 3. Illegal Phase Control
Guarantees `penable` is never driven HIGH unless `psel` is active, and ensures `pready` is not active prematurely during the `SETUP` phase.
```systemverilog
assert property (@(posedge clk) disable iff (prstn !== 1) psel == 0 |-> penable == 0) 
  else $error("penable high without psel");

assert property (@(posedge clk) disable iff (prstn !== 1) SETUP |-> pready !== 1) 
  else $error("pready asserted during SETUP which should only assert in ACCESS");
```

### 4. Bus Clean Up
Ensures `pready` drops immediately after the transfer completes.
```systemverilog
assert property (@(posedge clk) disable iff (prstn !== 1) ACCESS |=> pready !== 1) 
  else $error("pready not deasserted after ACCESS completed");
```

### 5. Reset Validity
Verifies the reset behavior accurately forces `pready`, `pslverr`, and `prdata` to 0 upon the falling edge of `prstn`.
```systemverilog
assert property (@(posedge clk) $fell(prstn) |=> (pready == 0 && pslverr == 0 && prdata == 0)) 
  else $error("fail to reset");
```

---

## Functional Coverage Matrix

To verify that the state space has been rigorously explored, a dedicated UVM metric tracker (`apb_cg`) monitors transactions with the following strategic coverage points:

```systemverilog
covergroup apb_cg;
    pwrite_cg: coverpoint tr.pwrite {
        bins pwrite_write = {1};
        bins pwrite_read  = {0};
    }
    pready_cg: coverpoint tr.pready {
        bins pready_high = {1};
        bins pready_low  = {0};
    }
    pslverr_cg: coverpoint tr.pslverr {
        bins pslverr_error     = {1};
        bins pslverr_non_error = {0};
    }
    paddr_cg: coverpoint tr.paddr {
        bins paddr_valid        = {[0:63]};
        bins paddr_out_of_range = {[64:80]};
    }
    phase_cg: coverpoint {vif.cb_mon.psel, vif.cb_mon.penable} {
        bins idle   = {2'b00};
        bins setup  = {2'b10};
        bins access = {2'b11};
    }
endgroup
```

---

## Simulation & Execution

The test suite executes multi-scenario constraints, actively testing:
* **Back-to-back continuous random transactions** to simulate maximum bandwidth stress on the bus interface.
* **Out-of-bounds memory accesses** (`paddr` between `[64:80]`) to intentionally trigger, observe, and verify the slave's error (`PSLVERR`) compliance response.

### Execution Tooling
This project is fully compliant with **Synopsys VCS 2025** on EDA Playground.

**VCS Compile Options Used:**
```bash
-timescale=1ns/1ns +vcs+flush+all +warn=all -sverilog
```

---

## Future Enhancements

* Integrate verification testing for the configurable hardware parameter `EN_WAIT_DELAY_FUNC` to handle slave-inserted variable wait cycles.
* Incorporate Register Layer (**UVM RAL**) abstraction blocks for standardized memory access handling.