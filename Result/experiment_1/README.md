# Minisys-1 单周期 CPU 设计 —— 实验一交付包

## 复现步骤

### 环境要求
- Vivado 2019.2（其他版本也可，但推荐 2019.x）
- Windows 操作系统

### 步骤 1：创建工程
1. 打开 Vivado → **Create Project** → Next
2. Project name: `Minisys1_CPU`，位置选纯英文路径（如 `D:\Minisys1_CPU`）
3. 选择 **RTL Project**，勾选 "Do not specify sources at this time" → Next
4. 芯片选择（关键！）:
   - Family: **Artix-7**
   - Package: **fgg484**
   - Part: **xc7a100tfgg484-1**
5. Next → Finish

### 步骤 2：添加源文件
1. Flow Navigator → **Add Sources** → **Add or create design sources**
2. 点 `+` → **Add Files** → 全选 `sources/minisys/` 下所有 `.v` 文件
3. 勾选 **Copy sources into project** → Finish

### 步骤 3：添加约束文件
1. Flow Navigator → **Add Sources** → **Add or create constraints**
2. 点 `+` → **Add Files** → 选 `sources/constraints/minisys.xdc`
3. 勾选 **Copy constraints into project** → Finish

### 步骤 4：生成 IP 核

#### 4.1 cpuclk（Clocking Wizard）
1. IP Catalog → 搜索 `clocking` → 双击 **Clocking Wizard**
2. Component Name: `cpuclk` → OK
3. **Clocking Options**:
   - Primary: 100.000 MHz, Single ended
4. **Output Clocks**:
   - clk_out1: Requested = 23.000 MHz
   - clk_out2: Requested = 10.000 MHz (点 + 添加)
5. OK → Generate

#### 4.2 prgrom（Block Memory Generator, 程序 ROM）
1. IP Catalog → 搜索 `block memory` → 双击 **Block Memory Generator**
2. Component Name: `prgrom` → OK
3. **Basic**: Memory Type = Single Port ROM, Width = 32, Depth = 16384, Always Enabled
4. **Other Options**: 勾选 Load Init File → 选 `sources/ip/prgmip32.coe`
5. OK → Generate

#### 4.3 ram（Block Memory Generator, 数据 RAM）
1. IP Catalog → 搜索 `block memory` → 双击 **Block Memory Generator**
2. Component Name: `ram` → OK
3. **Basic**: Memory Type = Single Port RAM, Width = 32, Depth = 16384, Always Enabled
4. **Other Options**: 勾选 Load Init File → 选 `sources/ip/dmem32.coe`
5. OK → Generate

### 步骤 5：仿真验证（可选）
1. Flow Navigator → **Add Sources** → **Add or create simulation sources**
2. 添加 `sources/sim/minisys_sim.v` → Finish
3. Flow Navigator → **Run Simulation** → **Run Behavioral Simulation**
4. Tcl Console 输入:
   ```
   restart
   run 20000ns
   get_value /minisys_sim/u/clock
   get_value /minisys_sim/u/pc_plus_4
   get_value /minisys_sim/u/instruction
   ```
5. 预期结果：clock=1, pc_plus_4=0x78, instruction 为有效指令

### 步骤 6：综合（Synthesis）
1. Flow Navigator → **Run Synthesis** → OK
2. 等待完成，无 Error 即通过

### 步骤 7：实现（Implementation）
1. Flow Navigator → **Run Implementation** → OK
2. 等待完成，无 Error 即通过

### 步骤 8：生成比特流（Bitstream）
1. Flow Navigator → **Generate Bitstream** → OK
2. 生成完成后 Cancel（不需要 Hardware Manager）
3. `.bit` 文件位于 `<工程目录>/Minisys1_CPU.runs/impl_1/minisys.bit`

### 步骤 9：下载到开发板（可选）
1. 用 USB-JTAG 连接 Minisys 开发板
2. Flow Navigator → **Open Hardware Manager** → **Open Target** → **Auto Connect**
3. **Program Device** → 选择 minisys.bit → Program

---

## 文件结构

```
deliverables/
├── README.md                          # 本文件
├── docs/
│   ├── 实验一报告.md                   # 完整实验报告（需求分析→测试结果）
│   └── 实验一_功能实现说明.md           # 各模块实现原理 + 实验二交接说明
├── sources/
│   ├── minisys/                       # Verilog 源文件 (14个)
│   │   ├── minisys.v                  # 顶层模块
│   │   ├── ifetc32.v                  # 取指单元
│   │   ├── idecode32.v                # 译码单元
│   │   ├── control32.v                # 控制器
│   │   ├── executs32.v                # 执行单元
│   │   ├── dmemory32.v                # 数据存储器
│   │   ├── programrom.v               # 程序存储器
│   │   ├── memorio.v                  # 存储器/IO 路由
│   │   ├── ioread.v                   # IO 读多路选择
│   │   ├── leds.v                     # LED 输出
│   │   ├── switchs.v                  # 拨码开关输入
│   │   ├── upg.v                      # UART 程序下载封装
│   │   ├── uart_bmpg.v                # UART 程序下载核心
│   │   └── uart_bmpg.edif             # UART 程序下载网表
│   ├── ip/
│   │   ├── prgmip32.coe               # 程序 ROM 初始化文件
│   │   └── dmem32.coe                 # 数据 RAM 初始化文件
│   ├── sim/
│   │   └── minisys_sim.v              # 行为仿真测试平台
│   ├── constraints/
│   │   └── minisys.xdc                # 引脚约束文件
│   └── minisys.bit                    # 最终的比特流文件
```

## 常见问题

**Q: 综合时提示 `module 'uart_bmpg_0' not found`**
A: 确保已将 `upg.v`, `uart_bmpg.v`, `uart_bmpg.edif` 全部添加到工程。

**Q: Implementation 时引脚不匹配**
A: 检查芯片是否选为 `xc7a100tfgg484-1`（不是 csg324）。

**Q: [Place 30-574] start_pg_IBUF 布线失败**
A: 确保 xdc 文件第4行已取消注释:
```
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets start_pg_IBUF]
```

**Q: .coe 文件加载失败**
A: .coe 文件路径不能含中文，使用本包中 `sources/ip/` 下的 coe 文件。
