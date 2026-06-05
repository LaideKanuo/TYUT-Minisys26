# Minisys1_CPU 实验二交付包

> 基于MIPS指令系统的单周期Minisys-1 CPU简单接口设计

---

## 目录结构

```
deliverables/
├── README.md                    ← 本文件
├── docs/
│   ├── 实验二报告.md            ← 实验二完整报告
│   ├── 实验二_功能实现说明.md    ← 模块功能说明
│   └── 实验二诊断书.md          ← 队友代码问题诊断（13个问题详情）
├── sources/
│   ├── minisys/                 ← Verilog 设计源文件（14个）
│   │   ├── control32.v         （重写）控制器扩展，17端口+IO译码
│   │   ├── digitube.v          （新建）数码管驱动，动态扫描+BCD译码
│   │   ├── idecode32.v         （修改）修复JAL写$31 Bug
│   │   ├── ioread.v            （重写）+数码管读通道，修latch
│   │   ├── memorio.v           （修改）+DigitubeCtrl片选
│   │   ├── minisys.v           （重写）顶层集成，+seg/an端口
│   │   ├── ifetc32.v           （不变）
│   │   ├── executs32.v         （不变）
│   │   ├── dmemory32.v         （不变）
│   │   ├── programrom.v        （不变）
│   │   ├── leds.v              （不变）
│   │   ├── switchs.v           （不变）
│   │   ├── uart_bmpg.v         （不变）
│   │   └── upg.v               （不变）
│   ├── constraints/
│   │   └── minisys.xdc         （修改）+数码管引脚占位（待补）
│   ├── ip/
│   │   ├── dmem32.coe          （不变）数据RAM初始化文件
│   │   └── prgmip32.coe        （不变）程序ROM初始化文件
│   └── sim/
│       └── minisys_sim.v       （修改）+seg/an端口
└── digitube_test.asm           （新建）数码管测试汇编程序
```

---

## 与实验一的关系

实验二在实验一基础上进行了三项接口扩展：

1. **控制器扩展** — 增加 IO 地址译码（区分内存/IO访问），拆分访存控制信号
2. **数码管模块添加** — 新建 digitube.v，驱动两个4位七段数码管（基地址 0xFFFFFC80）
3. **IO 路由完善** — memorio.v/ioread.v 增加数码管通道，修复 ioread latch

同时修复了实验一的两个潜伏 Bug：
- Bug #7：JAL 指令写回目标寄存器地址错误（固定写 $31）
- Bug #8：JR 指令 RegWrite 未排除

---

## Vivado 全流程验证状态

| 阶段 | 结果 |
|------|------|
| 行为仿真（编译+elaboration） | 通过 |
| 仿真运行（20μs & 5ms） | 通过（CPU 正常运行） |
| 综合（synth_design） | 0 Error |
| 优化（opt_design） | 0 Error |
| 布局（place_design） | 0 Error, WNS=0.911ns |
| 布线（route_design） | 0 Error, 0 unrouted nets |
| 比特流（write_bitstream） | 阻塞 — 数码管引脚约束未补 |

**工程路径**：`D:\All_Project\TemporaryFileExtraction\Practice\All_Projects\Minisys1_CPU_Ex2\`

---

## 遗留工作

1. 从 Minisys 板文档中找到 seg[7:0] 和 an[3:0] 的 FPGA 引脚号，填入 `sources/constraints/minisys.xdc`
2. 确认数码管共阳极/共阴极（当前按共阳极编写，0=亮）
3. 补完引脚约束后直接 `write_bitstream` 即可生成比特流（无需重跑综合/实现）
