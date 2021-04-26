# Execute like: PROGRAM_NAME=alu_test ./build.sh
echo "Building with ${PROGRAM_NAME}"
# Clean
rm *.json *.asc *.bin *.cf

# Simulate
ghdl -a --std=08 *.vhdl || exit 1
# Synthesize (and generate outputs for SVG render)
yosys -p "ghdl --std=08 ${PROGRAM_NAME}; synth_ice40 -json ${PROGRAM_NAME}.json;" || exit 1
# Route, generate, and flash
nextpnr-ice40 --up5k --package sg48 --pcf pins.pcf --json "${PROGRAM_NAME}.json" --asc "${PROGRAM_NAME}.asc" || exit 1
icepack "${PROGRAM_NAME}.asc" "${PROGRAM_NAME}.bin" || exit 1
iceprog "${PROGRAM_NAME}.bin" || exit 1
