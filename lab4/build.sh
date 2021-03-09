# Execute like: PROGRAM_NAME=alu_test ./build.sh
echo "Building with ${PROGRAM_NAME}"

# Simulate
ghdl -a *.vhdl
# Synthesize (and generate outputs for SVG render)
yosys -p "ghdl ${PROGRAM_NAME}; synth_ice40 -json ${PROGRAM_NAME}.json;"
# Route, generate, and flash
nextpnr-ice40 --up5k --package sg48 --pcf pins.pcf --json "${PROGRAM_NAME}.json" --asc "${PROGRAM_NAME}.asc"
icepack "${PROGRAM_NAME}.asc" "${PROGRAM_NAME}.bin"
iceprog "${PROGRAM_NAME}.bin"
