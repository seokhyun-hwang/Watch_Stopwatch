# ⏱️ FPGA Smart Watch & Stopwatch

<img src="https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge&logo=verilog" />
<img src="https://img.shields.io/badge/Tool-Vivado-red?style=for-the-badge&logo=xilinx" />
<img src="https://img.shields.io/badge/Board-Basys3-green?style=for-the-badge&logo=fpga" />

**FPGA와 PC 간의 UART 통신 제어를 결합한 하이브리드 디지털 시계 프로젝트**

</div>

---

## 📖 프로젝트 개요 (Project Overview)

이 프로젝트는 **Basys 3 FPGA 보드**를 활용하여 **디지털 시계(Watch)**와 **스톱워치(Stopwatch)** 기능을 구현한 결과물입니다.
단순히 하드웨어 버튼으로만 제어하는 것을 넘어, **UART 통신**을 통해 PC에서 명령어를 보내 FPGA를 제어하는 기능을 탑재했습니다. 특히 물리적 스위치와 PC 제어 신호 간의 **우선순위 충돌 문제를 해결**하여 안정적인 동작을 보장하도록 설계되었습니다.

---

## 🚀 주요 기능 (Key Features)

### 1️⃣ 듀얼 모드 시간 관리 (Dual Mode Timekeeping)
* **🕒 Digital Watch:** 시, 분, 초 단위의 실시간 시계 기능.
* **⏱️ Stopwatch:** 1/100초(10ms) 단위의 정밀 타이머 기능 (Start, Stop, Clear).
* **🔄 모드 전환:** 스위치(`sw1`) 또는 UART 명령어를 통해 두 모드 간 디스플레이 전환 가능.

### 2️⃣ 하이브리드 제어 시스템 (Hybrid Control System)
* **물리 버튼 제어:** Debounce 회로가 적용된 FPGA 보드의 버튼을 통한 즉각적인 제어.
* **UART PC 제어:** PC 터미널에서 ASCII 문자를 전송하여 시계 및 스톱워치 원격 제어.
* **명령어 해석기 (Interpreter):** 수신된 ASCII 코드를 분석하여 내부 제어 펄스(Pulse) 신호로 변환.

### 3️⃣ 📺 디스플레이 (FND Controller)
* **Multiplexing:** 4자리 7-Segment Display를 시분할 구동하여 잔상 효과를 이용한 숫자 표시.
* **시각적 피드백:** 스톱워치 동작 시 Dot(.) 점멸 기능을 통해 동작 상태 직관적 확인.

---

## 🛠️ 하드웨어 아키텍처 (H/W Architecture)

이 프로젝트는 크게 **제어부(Control Unit)**와 **데이터 처리부(Datapath)**로 나뉩니다.

| 모듈명 (Module) | 역할 (Role) | 주요 상세 내용 |
| :--- | :--- | :--- |
| **watch_dp.v** | 시계 데이터패스 | 1초 틱(Tick)을 생성하여 시/분/초 카운팅 수행 |
| **stopwatch_dp.v** | 스톱워치 데이터패스 | 10ms 단위 카운팅, Start/Stop/Clear 상태에 따른 시간 유지 |
| **stopwatch_cu.v** | 스톱워치 제어부 | FSM(Finite State Machine)을 이용한 `RUN`, `STOP`, `CLEAR` 상태 전이 관리 |
| **combiner.v** | 데이터 병합 | 현재 모드(`sel`)에 따라 Watch와 Stopwatch 중 하나의 데이터를 FND로 전송 |
| **fnd_controller.v** | 디스플레이 컨트롤러 | 시/분/초 데이터를 받아 7-Segment에 동적 디스플레이(Dynamic Scanning) 구현 |
| **button_debounce.v** | 입력 안정화 | 기계적 스위치의 떨림(Chattering) 현상을 제거하여 안정적인 신호 생성 |

---

## ⚡ 기술적 도전 & 트러블슈팅 (Troubleshooting)

프로젝트 진행 중 발생한 주요 문제점과 이를 해결한 과정입니다.

### 🛑 문제점 1: 제어 권한 충돌 (Conflict)
* **현상:** 물리 스위치를 통해 모드를 변경하는 도중, UART 명령어가 입력되면 모드 상태가 꼬이거나 원치 않는 화면이 출력됨.
* **원인:** 두 개의 입력 소스(물리 스위치 vs PC 통신)가 동시에 하나의 제어 신호에 접근.
* **해결책 (Priority Logic):**
    * UART로 모드 전환 명령(`'m'`)이 수신되면 내부 플래그(`pc_mode_lock`)를 **High**로 설정.
    * 이 상태에서는 물리 스위치의 입력이 무시되도록 설계하여 **PC 제어에 우선권(Priority)**을 부여함.

### 🔄 문제점 2: 명령어 중복 실행 (Repeated Execution)
* **현상:** PC에서 '시작' 명령을 한 번 보냈으나, FPGA 내부 클럭 속도가 빨라 수신된 데이터가 유지되는 동안 명령이 수백 번 실행됨.
* **원인:** Level Trigger 방식의 신호 처리로 인해 데이터가 유효한 기간 동안 계속 `High`로 인식됨.
* **해결책 (Edge Detection):**
    * UART FIFO의 `rx_empty` 신호가 해제되는 순간을 감지하는 **Edge Detector** 구현.
    * 데이터가 들어온 **그 순간 딱 1 클럭 동안만** `valid_pulse`를 생성하도록 변경하여 명령어 중복 실행 방지.

---

## 💡 배운 점 (Lessons Learned)

1.  **UART 프로토콜 구현:** RS-232 통신 규격을 이해하고, Baud Rate Generator와 FIFO를 포함한 송수신 모듈을 Verilog로 직접 설계하는 능력을 길렀습니다.
2.  **우선순위 제어 로직:** 다중 입력 소스(Multi-source Input)가 존재할 때 시스템의 안정성을 위해 제어 위계(Hierarchy)를 설정하는 것의 중요성을 배웠습니다.
3.  **디지털 회로의 타이밍:** Debounce 처리와 Edge Detection을 통해 하드웨어의 미세한 타이밍 이슈를 해결하며 실무적인 회로 설계 감각을 익혔습니다.

---

## 📂 폴더 구조 (Project Structure)

```bash
📦 FPGA_Watch_Project
 ├── 📂 src
 │    ├── 📜 top.v                # 최상위 모듈 (UART + Watch 통합)
 │    ├── 📜 watch_dp.v           # 시계 카운터 로직
 │    ├── 📜 stopwatch_dp.v       # 스톱워치 데이터패스
 │    ├── 📜 stopwatch_cu.v       # 스톱워치 FSM 제어기
 │    ├── 📜 fnd_controller.v     # 7-Segment 디스플레이 제어
 │    ├── 📜 button_debounce.v    # 버튼 입력 디바운싱
 │    └── 📜 combiner.v           # 출력 데이터 MUX
 ├── 📂 constraint
 │    └── 📜 Basys-3-Master.xdc   # 핀 맵핑 파일
 └── 📜 README.md
