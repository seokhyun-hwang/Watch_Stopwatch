# ⏱️ FPGA Smart Watch & Stopwatch

> **Basys 3 보드의 물리 버튼과 스위치를 활용한 독립형 디지털 시계 및 스톱워치 설계**

<br>

![Device](https://img.shields.io/badge/Device-Basys3_(Artix--7)-78C922?style=for-the-badge&logo=microchip&logoColor=white)
![Language](https://img.shields.io/badge/Language-Verilog_HDL-007ACC?style=for-the-badge&logo=verilog&logoColor=white)
![Tool](https://img.shields.io/badge/Tool-Vivado-FF5252?style=for-the-badge&logo=xilinx&logoColor=white)
![Protocol](https://img.shields.io/badge/Protocol-UART_RS232-FF7F50?style=for-the-badge)

<br>

## 📖 프로젝트 개요 (Project Overview)

이 프로젝트는 **Basys 3 FPGA 보드**를 활용하여 디지털 시계(Watch)와 스톱워치(Stopwatch) 기능을 구현한 결과물입니다.
FPGA 내부 로직과 물리적 입출력 장치(Switch, Button, 7-Segment Display)로 동작하도록 설계되었습니다. 특히 기계적 스위치의 노이즈를 제거하는 **디바운싱(Debouncing)** 기술과 정확한 시간 계수를 위한 **클럭 분주(Clock Division)** 설계에 중점을 두었습니다.

<br>

## 🚀 주요 기능 (Key Features)

### 1️⃣ 듀얼 모드 시간 관리 (Dual Mode Timekeeping)
* **🕒 Digital Watch:** 시(Hour), 분(Min), 초(Sec) 단위의 실시간 시계 기능 (24시간제).
* **⏱️ Stopwatch:** 1/100초(10ms) 단위의 정밀 타이머 기능.
* **🔄 모드 전환:** 보드의 스위치(`sw1`) 조작을 통해 시계 모드와 스톱워치 모드 간 화면 전환 가능.

### 2️⃣ 하드웨어 제어 시스템 (Hardware Control System)
* **시간 설정:** 시계 모드에서 버튼을 눌러 시/분/초를 개별적으로 조정 가능.
* **스톱워치 제어:**
    * **Run/Stop:** 버튼을 눌러 카운팅 시작 및 일시 정지.
    * **Clear:** 정지 상태에서 시간을 `00:00.00`으로 초기화.
* **입력 안정화:** 모든 버튼 입력에 Debounce 모듈을 적용하여 오작동(Chattering) 방지.

### 3️⃣ 📺 디스플레이 (FND Controller)
* **Multiplexing:** 4자리 7-Segment Display를 고속(1kHz)으로 시분할 구동하여 잔상 효과를 이용한 숫자 표시.
* **Visual Feedback:**
    * 시계 모드: `시:분` 표시 (초 단위는 내부 카운팅).
    * 스톱워치 모드: `초.밀리초` 표시 및 동작 중 Dot(.) 점멸 기능 지원.

<br>

## 🛠️ 하드웨어 아키텍처 (H/W Architecture)

이 프로젝트는 크게 **타이밍 생성부**, **제어부**, 그리고 **데이터 처리부**로 나뉩니다.

| 모듈명 (Module) | 역할 (Role) | 주요 상세 내용 |
| :--- | :--- | :--- |
| **clock_top.v** | 최상위 모듈 | 시스템 클럭, 버튼 입력, FND 출력을 연결하는 Top Wrapper |
| **watch_dp.v** | 시계 데이터패스 | 1Hz(1초) 틱을 생성하여 시/분/초 카운터 동작 및 오버플로우(60초/60분/24시) 처리 |
| **stopwatch_dp.v** | 스톱워치 데이터패스 | 100Hz(10ms) 틱 기반 카운팅 로직 |
| **stopwatch_cu.v** | 스톱워치 제어부 | FSM(Finite State Machine)을 이용한 `STOP`, `RUN`, `CLEAR` 상태 전이 관리 |
| **fnd_controller.v** | 디스플레이 컨트롤러 | 입력된 시간 데이터를 7-Segment의 Segment 신호와 Digit 선택 신호로 변환 (Dynamic Scanning) |
| **button_debounce.v** | 입력 안정화 | 기계적 스위치의 떨림(Bouncing) 현상을 제거하여 깨끗한 펄스 신호 생성 |

<br>

## 🎮 조작 방법 (Controls)

**Basys 3 Board**의 물리적 요소를 사용하여 제어합니다.

### 1. 스위치 설정
* **SW[0] (Enable):** 전체 시스템 활성화 (ON 상태여야 동작).
* **SW[1] (Mode Select):**
    * `OFF (0)`: 스톱워치 모드.
    * `ON (1)`: 디지털 시계 모드.

### 2. 버튼 기능 (Mode에 따라 다름)

| 버튼 (Button) | 스톱워치 모드 (Stopwatch) | 시계 모드 (Watch) |
| :---: | :--- | :--- |
| **Btn_R** | **Run / Stop** 토글 | (기능 없음) |
| **Btn_L** | **Clear** (정지 상태일 때) | **Hour** 증가 (시간 설정) |
| **Btn_U** | (기능 없음) | **Minute** 증가 (분 설정) |
| **Btn_D** | (기능 없음) | **Second** 증가 (초 설정) |

<br>

## ⚡ 기술적 도전 & 트러블슈팅 (Troubleshooting)

프로젝트 진행 중 발생한 하드웨어적 문제점과 해결 과정입니다.

### 🛑 문제점 1: 스위치 채터링 (Switch Bouncing)
* **현상:** 버튼을 한 번 눌렀음에도 불구하고 카운터가 여러 번 증가하거나 스톱워치가 시작하자마자 멈추는 현상 발생.
* **원인:** 기계식 버튼 내부의 접점이 붙거나 떨어질 때 미세한 진동으로 인해 수십 ms 동안 High/Low 신호가 반복됨.
* **해결책 (Debouncing):**
    * 샘플링 기법을 적용하여 일정 시간(약 20ms) 동안 신호가 안정적으로 유지될 때만 유효한 입력으로 간주하는 `button_debounce` 모듈을 구현하여 해결.

### ⏱️ 문제점 2: 타이밍 오차 (Timing Inaccuracy)
* **현상:** 스톱워치를 장시간 동작시켰을 때, 실제 시간(스마트폰 스톱워치)과 미세한 차이가 발생함.
* **원인:** 100MHz 시스템 클럭을 분주하는 과정에서 카운터 조건 설정 미흡으로 인한 1 클럭 오차 누적.
* **해결책 (Precise Prescaler):**
    * 100MHz 클럭에서 정확히 10ms(100Hz)를 생성하기 위한 카운터 상수를 정확하게 계산하여 적용 (`cnt == 1_000_000 - 1`).
    * 조건문(`>=` 대신 `==`)을 명확히 사용하여 불필요한 클럭 사이클 낭비를 방지.

<br>

## 📂 발표 자료 (Materials)

프로젝트에 대한 발표자료를 확인하실 수 있습니다.

[![PDF Report](https://img.shields.io/badge/📄_PDF_Report-View_Document-FF0000?style=for-the-badge&logo=adobeacrobatreader&logoColor=white)](https://github.com/seokhyun-hwang/files/blob/main/watch_stopwatch_verilog.pdf)

<br>

## 📂 폴더 구조 (Project Structure)

```bash
📦 FPGA_Watch_Project
 ├── 📂 src
 │   ├── 📜 clock_top.v          # [Top] 최상위 모듈 (Watch + Stopwatch 통합)
 │   ├── 📜 watch.v              # 시계 Top 모듈
 │   ├── 📜 watch_dp.v           # 시계 카운터 및 시간 로직
 │   ├── 📜 stopwatch.v          # 스톱워치 Top 모듈
 │   ├── 📜 stopwatch_dp.v       # 스톱워치 데이터패스 (1/100초 카운터)
 │   ├── 📜 stopwatch_cu.v       # 스톱워치 FSM 제어기 (Run/Stop/Clear)
 │   ├── 📜 fnd_controller.v     # 7-Segment 디스플레이 스캐닝 제어
 │   └── 📜 button_debounce.v    # 버튼 채터링 방지 모듈
 ├── 📂 constraint
 │   └── 📜 Basys-3-Master.xdc   # FPGA 핀 맵핑 파일
 └── 📜 README.md
````

<br>

-----

Copyright ⓒ 2024 SEOKHYUN HWANG. All rights reserved.

```
```
