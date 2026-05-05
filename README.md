# HDMI-FPGA-Implementation-
An FPGA-based HDMI display system for real-time IR (thermal) imaging. The design includes AXI4-Stream video generation, frame timing control, and synchronization with HDMI output. Supports interlaced NTSC video formats and handles frame rate adaptation between input (ADC) and output (HDMI).
# FPGA-Based HDMI IR Image Display

## 📌 Overview
This project implements a **real-time HDMI video pipeline on FPGA** to display **infrared (IR) / thermal images**.  
The system captures pixel data from an **ADC / BT.656 interface**, processes it inside the FPGA, and streams it to an HDMI display using **AXI4-Stream protocol**.

The design focuses on **frame synchronization, buffering, and continuous video output**, ensuring stable display even when input and output frame rates differ.

---

## 🚀 Features
- Real-time IR image capture and display
- HDMI output using AXI4-Stream video interface
- BT.656 / ADC input processing
- Frame synchronization between input (ADC) and output (HDMI)
- FIFO-based clock domain crossing (CDC)
- Grayscale to RGB conversion for HDMI
- Test pattern generation support (debugging)
- Designed for scalability (can be extended to 1080p)

---

## 🏗️ System Architecture
    +-------------------+
    |   IR Sensor / ADC |
    +---------+---------+
              |
              | BT.656 / Parallel Data
              v
    +-------------------+
    |  Video Capture    |
    |  (SAV/EAV Detect) |
    +---------+---------+
              |
              v
    +-------------------+
    |   FIFO Buffer     |
    | (CDC Handling)    |
    +---------+---------+
              |
              v
    +-------------------+
    | AXI4-Stream Video |
    |   Processing      |
    +---------+---------+
              |
              v
    +-------------------+
    |    HDMI TX        |
    +-------------------+
              |
              v
         HDMI Display

---

## ⚙️ Key Modules

### 1. Video Capture (BT.656 Decoder)
- Detects **SAV (Start of Active Video)** and **EAV (End of Active Video)**
- Extracts valid pixel data
- Tracks:
  - `x_pos` (horizontal pixel)
  - `y_pos` (line count)

---

### 2. Frame Control Logic
- Skips initial unstable frames from ADC
- Enables capture only after stabilization
- Controls:
  - `fifo_rst`
  - `Enable_adc`
  - frame alignment with HDMI

---

### 3. FIFO (Clock Domain Crossing)
- Dual-clock FIFO:
  - Write clock → ADC (`llc_buffered`)
  - Read clock → HDMI (`aclk`)
- Prevents data loss due to:
  - frame rate mismatch (e.g., 59.94 vs 60 Hz)
- Ensures continuous HDMI output

---

### 4. AXI4-Stream Interface
- Handles:
  - `tvalid`, `tready`
  - `tuser` (frame start)
  - `tlast` (line end)
- Passes HDMI timing while injecting pixel data

---

### 5. HDMI Output
- Converts grayscale pixel to RGB:
- - Outputs 48-bit data (16 bits per channel)

---

## 📊 Data Flow

1. ADC provides pixel stream (BT.656 format)
2. FPGA detects valid video region
3. Pixels are written into FIFO
4. HDMI side reads FIFO using AXI timing
5. Data is converted and displayed

---

## 🧠 Key Design Challenges

### 🔹 Frame Rate Mismatch
- ADC: ~59.94 Hz  
- HDMI: ~60 Hz  
- Solved using:
- FIFO buffering
- Frame skipping strategy

---

### 🔹 Clock Domain Crossing
- ADC and HDMI operate on different clocks  
- Solved using:
- Dual-clock FIFO

---

### 🔹 Initial Frame Instability
- First few frames from ADC may be invalid  
- Solution:
- Skip first N frames before enabling capture

---

## 🛠️ Tools & Technologies
- **FPGA**: Xilinx (Vivado)
- **Language**: Verilog / VHDL
- **Protocols**:
- AXI4-Stream
- BT.656
- HDMI
- **Debugging**:
- ILA (Integrated Logic Analyzer)

---

## 📁 Project Structure

---

## ▶️ How to Run

1. Open project in **Vivado**
2. Synthesize and implement design
3. Program FPGA
4. Connect:
   - ADC / IR sensor input
   - HDMI display
5. Observe real-time IR image output

---

## 🧪 Testing

- Test pattern generation included for validation
- MATLAB scripts can be used to visualize captured frames from CSV

---

## 📸 Results

- Real-time grayscale IR image displayed on HDMI monitor
- Stable output after frame synchronization
- Smooth streaming without tearing

---

## 🔮 Future Improvements
- Color mapping (thermal palette instead of grayscale)
- Resolution upscaling (e.g., 640×480 → 1920×1080)
- DDR buffering for large frame storage
- Integration with image processing algorithms (NUC, BPR, filtering)
- MIPI CSI / DSI support

---

## 🤝 Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

---

## 📜 License
This project is open-source and available under the MIT License.

---

## 👤 Author
**Haris**  
FPGA Design Engineer  
Specializing in:
- Video Processing
- MIPI / HDMI / SDI Interfaces
- Thermal Imaging Systems
        
