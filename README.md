# ch573-xmake-template

使用xmake编译CH573项目

Build CH573(a 32-bit RISC-V Bluetooth Low energy MCU) by xmake.

----
## 1. TODO list

1) :white_check_mark: xmake工程创建
2) :white_check_mark: CH573基础SDK编译（参考ADC例程）
3) :white_check_mark: 除BLE和USB外的例程编译
4) :white_check_mark: USB的SDK添加及例程编译
5) :white_large_square: vscode-clangd代码提示的支持
6) :white_large_square: BLE的SDK添加及例程编译

----
## 2. 如何使用

### 2.1 测试环境
- 硬件：MacBook Air (M1, 2020)
- 系统：macOS Monterey 12.5.1

### 2.2 编译方法
1) 下载编译工具链并将其解压至任意目录
```
curl -O http://file.mounriver.com/tools/MRS_Toolchain_MAC_V150.zip
```

2) 设置环境变量`WCH_RISCV_SDK`或在*xmake.lua*中指定编译工具链路径，见
```
local sdk_dir = os.getenv("WCH_RISCV_SDK")
    or "opt/wchtools/xpack-riscv-none-embed-gcc-8.2.0"
```

3) 在`./src`中添加自己的项目代码后编译即可
```
xmake
```
若想在编译过程中查看详情则可使用
```
xmake -v
```

4) 在`./build/cross/riscv`中即可找到编译生成的文件
