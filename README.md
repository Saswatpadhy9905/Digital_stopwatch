# Digital_stopwatch
Stopwatch_fpga
# ⏱️ Digital Stopwatch in Verilog (Simulated)

This is a pure Verilog implementation of a **digital stopwatch**, featuring MM:SS time format, start/stop/reset controls, and a 4-digit 7-segment display (multiplexed). It is fully tested in simulation and built with modular, synthesizable Verilog code.

> ⚠️ Note: This project is **simulation-only** .

---

## 🔧 Features

- Start, Stop, and Reset control
- MM:SS time counting logic
- 4-digit multiplexed 7-segment display
- Clock divider logic (1Hz & 1kHz simulation clocks)
- Modular, clean codebase with testbench
- GTKWave waveform output for verification

---

## 🧩 Modules Breakdown

| Module                 | Description                                         |
|------------------------|-----------------------------------------------------|
| `clk_divider`          | Simulates division of input clock to 1Hz and 1kHz   |
| `stopwatch_counter`    | Implements stopwatch counting logic                 |
| `display_mux`          | Time-multiplexes 4-digit BCD display                |
| `seven_segment_decoder`| Converts BCD digit to active-low 7-segment encoding |
| `top`                  | Connects all modules                                |
| `stopwatch_tb`         | Testbench for simulation                            |

---

## 🧪 Simulation Instructions

### Using Icarus Verilog + GTKWave:

```bash
# Compile
iverilog -o sim.out stopwatch_digital.v

# Run simulation
vvp sim.out

# View waveform
gtkwave stopwatch.vcd
