# SystemVerilog Learning Lab

This repository is a small, hands-on environment for learning SystemVerilog. It keeps RTL designs, testbenches, source lists, and tool commands in one place so you can edit a design, simulate it, inspect its waveforms, and view a synthesized RTL schematic.


## Features

- **Repeatable tool environment:** Docker installs Verilator, Yosys, GTKWave, Graphviz, and xdot on Ubuntu 24.04.
- **SystemVerilog simulation:** Verilator compiles the selected design and testbench into a runnable executable.
- **Testbenches:** Examples demonstrate stimulus, assertions, random values, and VCD waveform dumping.
- **Waveform inspection:** GTKWave can display signal changes recorded by testbenches.
- **RTL schematic view:** Yosys processes a design and Graphviz/xdot render its structure.
- **Simple command interface:** A Makefile provides build, enter, simulate, waveform, schematic, and clean targets.

## Requirements

Install Docker and GNU Make on the host. Graphical applications launched inside the container need a working desktop display. The Makefile includes display forwarding for native Linux (X11/XWayland) and WSL2 with WSLg. Other host setups may need adjustments to the GUI variables and mounts in the Makefile.

## Quick start

Clone this repository:

```sh
git clone https://github.com/PrasannahRam/SV_Course
cd SV_Course 
```

Run these commands from the repository root on the host:

```sh
make build
make enter
```

`make build` creates the local image named `sv-course`. `make enter` starts an interactive container and mounts this repository at `/workspace`; edits made in the container are therefore edits to the host checkout. Run the remaining commands from the container shell.

For example, simulate the parameterized adder:

```sh
make sim FILE=n_bit_fa
```

View its waveform:

```sh
make wave FILE=n_bit_fa
```

Generate and open its RTL schematic:

```sh
make rtl FILE=n_bit_fa
```

Exit the container with `exit`. Back on the host, remove generated simulation and schematic outputs with:

```sh
make clean
```

## Make targets

| Target | Where to run | Purpose |
| --- | --- | --- |
| `make build` | Host | Build the Docker image. |
| `make enter` | Host | Start an interactive container with the project mounted at `/workspace`. |
| `make sim FILE=<name>` | Container | Compile and run `tb/<name>_tb.sv` with its source list. |
| `make wave FILE=<name>` | Container | Compile and run with tracing, then open `waveform.vcd` in GTKWave. |
| `make rtl FILE=<name>` | Container | Ask Yosys to process `src/<name>.sv`, create a DOT and SVG schematic under `rtl/`, and open the DOT in xdot. |
| `make clean` | Host or container | Remove `obj_dir/`, `rtl/`, and `waveform.vcd` generated outputs. |

`sim`, `wave`, and `rtl` require a `FILE` value. The simulation and waveform targets use `linkers/<name>.f` and expect the testbench top module to be named `<name>_tb`. The waveform target also expects the testbench to call `$dumpfile` and `$dumpvars`.

## Repository layout

```text
.
├── Dockerfile          # Open-source toolchain and container setup
├── Makefile            # Commands for building, entering, simulating, and viewing
├── src/                # Synthesizable SystemVerilog designs
├── tb/                 # Simulation testbenches
├── linkers/            # Verilator file lists: design and testbench inputs
└── Readme.md           # Project guide
```

Current examples:

| Design | RTL | Testbench | File list |
| --- | --- | --- | --- |
| Full adder | `src/full_adder.sv` | `tb/full_adder_tb.sv` |  `linkers/full_adder.f` |
| N-bit full adder | `src/n_bit_fa.sv` plus `src/full_adder.sv` | `tb/n_bit_fa_tb.sv` | `linkers/n_bit_fa.f` |
| ALU | `src/alu.sv` | `tb/alu_tb.sv` | `linkers/alu.f` |



## Adding an example

For a new design called `counter`:

1. Add the module to `src/counter.sv` and choose its top-level module name.
2. Add a testbench in `tb/counter_tb.sv`; instantiate the design, drive inputs, and check outputs. Add `$dumpfile("waveform.vcd")` and `$dumpvars(...)` if you want to inspect waveforms.
3. Add `linkers/counter.f` with one source path per line, typically:

   ```text
    src/counter.sv
    src/clock_divider.sv
    src/reset_controller.sv
    src/register.sv
    tb/counter_tb.sv
   ```

  
4. Run `make sim FILE=counter`, `make wave FILE=counter`, or `make rtl FILE=counter` from the container.

The Makefile uses a shared convention: `FILE` determines the file list, simulation top (`<name>_tb`), and RTL path (`src/<name>.sv`, with top module `<name>`). If your module or testbench uses a different name, either follow that convention or adapt the corresponding Makefile command.

Note: The current RTL target reads only src/counter.sv and assumes the design module is named counter. The linker file is currently used by simulation and waveform generation, not RTL generation.

## How the environment is implemented

### Docker

The `Dockerfile` starts from Ubuntu 24.04 and installs the tools with the distribution package manager. Docker keeps the host setup small and makes the command-line tool versions consistent for contributors using the same image. The project directory is bind-mounted into the container, so generated files and source edits remain available in the checkout. The container runs as the host user's numeric UID/GID to avoid creating root-owned project files.

The Makefile passes display sockets and environment variables to support GUI tools. It has separate handling for WSLg and native Linux X11/XWayland. If your desktop differs, inspect `GUI_ENV`, `GUI_MOUNT`, `X11_MOUNT`, and `XAUTH_MOUNT` in the Makefile.

### Verilator

Verilator compiles SystemVerilog into a native executable. The Makefile enables binary execution, timing support, and tracing. Each `linkers/<name>.f` file declares the RTL and testbench sources for that example; keeping these lists explicit makes dependencies easy to see and update.

### GTKWave and VCD

Testbenches record value changes to `waveform.vcd`. GTKWave reads that file and lets you inspect signal values over simulation time. Because the filename is shared, run one example at a time and close GTKWave before replacing the waveform with another run.

### Yosys, Graphviz, and xdot

The `rtl` target runs Yosys through a basic synthesis-oriented sequence (`read_verilog -sv`, `hierarchy`, `proc`, and `opt`). Yosys writes a DOT graph, Graphviz converts it to SVG, and xdot opens the graph interactively. This target reads `src/<name>.sv` directly; if a design depends on other RTL modules, update the Yosys command in the Makefile to read those files too.

## Extending the setup

When adding or changing a tool, update the `apt-get install` list in `Dockerfile` and rebuild with `make build`. When adding a design, keep its RTL, testbench, and file list together under the naming convention above. For more advanced flows, the Makefile is the place to change compiler flags, top-module selection, waveform naming, or Yosys steps. Keep this README's examples and file table in sync with those changes.

## Notes

- The examples illustrate constructs and workflows; review and expand their checks before relying on them for hardware verification.
- `make wave` enables Verilator assertions. `make sim` currently uses the flags in `VFLAGS` without adding `--assert`.
- Yosys supports a subset of SystemVerilog. More advanced language features may require code changes or a different synthesis tool.
