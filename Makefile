SIM       = verilator
IMAGE     = sv-course

SRC_DIR   = src
TB_DIR    = tb
BUILD_DIR = obj_dir
RTL_DIR   = rtl

VFLAGS    = --binary --timing -Wno-fatal

# ---------------------------------------------------------------------------
# GUI support: works on WSL2 (WSLg) and on native Linux (X11 / Wayland+XWayland)
# ---------------------------------------------------------------------------
USER_NAME := $(shell id -un)
HOST_NAME := $(shell hostname)

# WSLg is present only on WSL2
IS_WSLG := $(wildcard /mnt/wslg)

X11_MOUNT := $(if $(wildcard /tmp/.X11-unix),-v /tmp/.X11-unix:/tmp/.X11-unix,)

# X authority cookie. Native Wayland desktops keep it in /run/user/<uid>/.mutter-Xwaylandauth.*
HOST_XAUTH  := $(if $(XAUTHORITY),$(XAUTHORITY),$(HOME)/.Xauthority)
XAUTH_MOUNT := $(if $(wildcard $(HOST_XAUTH)),-v $(HOST_XAUTH):/tmp/.Xauthority:ro -e XAUTHORITY=/tmp/.Xauthority,)

ifneq ($(IS_WSLG),)
# ---- WSL2 ----
GUI_ENV   := -e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
             -e XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir \
             -e PULSE_SERVER=$(PULSE_SERVER)
GUI_MOUNT := -v /mnt/wslg:/mnt/wslg
XHOST_CMD := true
else
# ---- Native Linux ----
# Do not hand the Wayland socket to the container; force GTK onto X11 (XWayland).
GUI_ENV   := -e XDG_RUNTIME_DIR=/tmp
GUI_MOUNT :=
# Allow this user's local processes (i.e. the container, same uid) to use the X server.
XHOST_CMD := $(if $(shell command -v xhost 2>/dev/null),xhost +SI:localuser:$(USER_NAME) >/dev/null 2>&1 || true,true)
endif

.PHONY: build enter sim wave rtl clean

# FILE is required for sim, wave and rtl. Example: make sim FILE=full_adder
ifneq ($(filter sim wave rtl,$(MAKECMDGOALS)),)
ifeq ($(FILE),)
$(error Please specify a file. Example: make sim FILE=full_adder)
endif
endif

# Build the docker image (run once, on the host)
build:
	docker build -t $(IMAGE) .

# Enter the container with the current directory mounted at /workspace (run on the host)
# --hostname matches the host so the X cookie is accepted; the prompt still shows "rtl-lab".
enter:
	@$(XHOST_CMD)
	docker run --rm -it \
		--hostname $(HOST_NAME) \
		--ipc=host \
		-u $(shell id -u):$(shell id -g) \
		-e HOME=/tmp \
		-e DISPLAY=$(DISPLAY) \
		-e GDK_BACKEND=x11 \
		-e NO_AT_BRIDGE=1 \
		$(GUI_ENV) \
		$(X11_MOUNT) \
		$(GUI_MOUNT) \
		$(XAUTH_MOUNT) \
		-v $(CURDIR):/workspace \
		$(IMAGE) \
		bash --rcfile /etc/sv-prompt.sh

# Simulate with Verilator (run inside the container)
sim:
	$(SIM) $(VFLAGS) --trace \
    	--top-module $(FILE)_tb \
    	-f linkers/$(FILE).f

	./$(BUILD_DIR)/V$(FILE)_tb

# Simulate with tracing, then open the waveform in GTKWave
# (the testbench must call $$dumpfile("waveform.vcd") and $$dumpvars)
wave:
	$(SIM) $(VFLAGS) --assert --trace  \
		--top-module $(FILE)_tb \
		-f linkers/$(FILE).f
	./$(BUILD_DIR)/V$(FILE)_tb
	gtkwave waveform.vcd

# Generate the RTL schematic with Yosys + Graphviz.
# Outputs: rtl/$(FILE).dot (opened in xdot) and rtl/$(FILE).svg
rtl:
	mkdir -p $(RTL_DIR)
	yosys -p "read_verilog -sv $(SRC_DIR)/$(FILE).sv; \
	          hierarchy -top $(FILE); \
	          proc; \
	          opt; \
	          show -format dot -viewer none -prefix $(RTL_DIR)/$(FILE)"
	dot -Tsvg $(RTL_DIR)/$(FILE).dot -o $(RTL_DIR)/$(FILE).svg
	xdot $(RTL_DIR)/$(FILE).dot

clean:
	rm -rf $(BUILD_DIR) $(RTL_DIR) waveform.vcd
