ghdl -a *.vhdl
yosys -p "ghdl test_switch; synth_ice40 -json test_switch.json"
nextpnr-ice40 --up5k --package sg48 --pcf ../../gpio.pcf --json test_switch.json --asc test_switch.asc
icepack test_switch.asc test_switch.bin
iceprog test_switch.bin
