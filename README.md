# Spartan-6 DSP48A1 Module

A high-performance arithmetic and signal processing module for FPGA applications, designed using the **Xilinx Spartan-6 DSP48A1** primitive. This module supports **multiplication, addition/subtraction, and cascaded operations**, with configurable pipeline registers for maximum efficiency.

## 📸 Block Diagram
![image](https://github.com/user-attachments/assets/69010982-0820-472a-adb1-29d5000048ad)

## 📌 Features

- **Fully parameterized DSP48A1 module** for optimized arithmetic operations.
- **Pre-adder/subtractor** for flexible computation.
- **18x18 multiplier** for efficient signal processing.
- **Configurable registers** to enhance data flow and synchronization.
- **Cascaded architecture support** for high-speed computations.
- **Flexible operand selection** using multiplexers.
- **Synchronous/Asynchronous reset** options.

## 🛠 Tools Used

- **Vivado** – Design synthesis and implementation.
- **Questa** – Simulation and functional verification.

## 🏗️ Module Breakdown

### 1️⃣ **DSP48A1 Core Module**
The **`DSP48A1`** module implements a **high-performance arithmetic unit** with configurable registers.

#### **📌 Parameters**
- **A0REG, A1REG, B0REG, B1REG, CREG, PREG, MREG, DREG** – Control pipeline registers.
- **CARRYINREG, CARRYOUTREG, OPMODEREG** – Control carry-in, carry-out, and operation mode registers.
- **CARRYINSEL** – Determines carry-in selection (`"OPMODE5"` or `"CARRYIN"`).
- **B_INPUT_SEL** – Chooses between `"DIRECT"` or `"CASCADE"` mode for operand `B`.
- **RSTTYPE** – Supports **synchronous (`"SYNC"`)** or **asynchronous (`"ASYNC"`)** resets.

#### **🔌 Inputs & Outputs**
- **Inputs:**  
  - `A`, `B`, `D`: 18-bit operands  
  - `C`, `PCIN`: 48-bit operands  
  - `BCIN`: 18-bit cascade input  
  - `OPMODE`: 8-bit operation selector  
  - `CLK`: Clock input  
  - Control signals: Reset (`RST*`), Clock Enable (`CE*`), Carry (`CARRYIN`)

- **Outputs:**  
  - `P`: 48-bit final result  
  - `M`: 36-bit multiplier output  
  - `PCOUT`, `BCOUT`: Cascade outputs  
  - `CARRYOUT`, `CARRYOUTF`: Carry outputs  

#### **🛠 Functional Overview**
- **Pre-adder/Subtractor**: Computes `D ± B0` based on `OPMODE[6]`.
- **Multiplexer Control**: Selects between **direct input, cascade input, or registered values**.
- **Multiplier Block**: Implements an **18x18-bit multiplication**.
- **Summation Block**: Adds/subtracts inputs based on `OPMODE[7]`.

---

### 2️⃣ **Register MUX Module (`reg_mux`)**
A **generic register-based multiplexer** for parameterized pipeline control.

#### **📌 Parameters**
- **RSTTYPE** – `"SYNC"` or `"ASYNC"` reset.
- **REG_WIDTH** – Defines the width of stored values.

#### **🔌 Inputs & Outputs**
- **Inputs:** `CLK`, `RST`, `CE`, `SEL`, `D`
- **Outputs:** `MUX_OUT` (selected register output)

---

## 🚀 Key Achievements

✅ **Modularized Design**  
- Separated **MUX register logic** into independent sub-modules (`reg_mux`).  
- Improved **readability, maintainability, and scalability**.

✅ **Optimized Pipeline Registers**  
- Reduced **latency** by utilizing **configurable registers** for operands, results, and control signals.

✅ **Efficient Arithmetic Processing**  
- Pre-adder/subtractor, **multiplier**, and **configurable sum logic** to enable flexible signal processing.

✅ **Cascaded Processing Support**  
- Enabled **multi-stage DSP processing** via `PCIN`, `BCIN`, `PCOUT`, and `BCOUT` signals.

## Reference:
For more details, feel free to check out the official documentation here:  [AMD Documentation](https://docs.amd.com/v/u/~ta5R6V5ywmej~eY5UAEpg)
