# 1. Download files and patch them to fix the root causes
python3 -c "
import urllib.request

print('files loading')
base = 'https://raw.githubusercontent.com/minhaemictt/testbench_APB_Slave_DUT/main/gls/'
urllib.request.urlretrieve(base + 'primitives.v', 'primitives.v')
urllib.request.urlretrieve(base + 'sky130_fd_sc_hd.v', 'sky130_fd_sc_hd.v')
urllib.request.urlretrieve(base + 'sky130_sram_2kbyte_1rw1r_32x512_8.v', 'sram.v')
urllib.request.urlretrieve(base + 'taxi_apb_ram_flatport.nl.v', 'netlist.v')
urllib.request.urlretrieve(base + 'taxi_apb_ram_flatport__nom_tt_025C_1v80.sdf', 'delays.sdf')

print('Patching sky130_fd_sc_hd.v...')
with open('sky130_fd_sc_hd.v', 'r') as f:
    text = f.read()
# 1. Remove the FUNCTIONAL macro so the 'specify' timing blocks are active
text = text.replace('\`define FUNCTIONAL', '// \`define FUNCTIONAL removed to enable TIMING')
# 2. Fix the Sky130 library's undeclared nettypes (Error vlog-2892)
text = text.replace('\`default_nettype none', '\`default_nettype wire')
# 3. Fix the malformed timing path in lpflow_bleeder_1 (Error vlog-13522)
text = text.replace('(SHORT => VPWR) = (0:0:0,0:0:0,0:0:0,0:0:0,0:0:0,0:0:0);', '// Patched vlog-13522')
with open('sky130_fd_sc_hd.v', 'w') as f:
    f.write(text)

print('Patching primitives.v...')
with open('primitives.v', 'r') as f:
    text = f.read()
text = text.replace('\`default_nettype none', '\`default_nettype wire')
with open('primitives.v', 'w') as f:
    f.write(text)

print('Patching sram.v to fix missing timescale...')
with open('sram.v', 'r') as f:
    text = f.read()
with open('sram.v', 'w') as f:
    f.write('\`timescale 1ns/1ps\n' + text)
"

# 2. Compile and Simulate using qrun
qrun -uvmhome uvm-1.2 -sv -top apb_ram_top_flatport -timescale 1ns/1ps \
  design.sv testbench.sv primitives.v sky130_fd_sc_hd.v sram.v netlist.v \
  -suppress 3438,12088,12090,3262 \
  -voptargs="+acc=npr" \
  -sdfmax /apb_ram_top_flatport/dut=delays.sdf