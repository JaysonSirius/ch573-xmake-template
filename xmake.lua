-- 设置工程名
set_project("ch573-xmake")
-- 设置工程版本
set_version("0.1.0", {build = "%Y%m%d%H%M"})

-- 编译模式，其中check模式用于内存检测
add_rules("mode.debug", "mode.release", "mode.check")

-- 定义交叉编译工具链
toolchain("wch-riscv-gcc")
    set_kind("standalone")
    local sdk_dir = os.getenv("WCH_RISCV_SDK")
        or "opt/wchtools/xpack-riscv-none-embed-gcc-8.2.0"
    set_sdkdir(sdk_dir)
toolchain_end()

-- 禁用flags的自动检测和忽略机制
set_policy("check.auto_ignore_flags", false)

target("ch573")
    -- 编译为二进制程序
    set_kind("binary")
    -- 设置编译平台
    set_plat("cross")
    -- 设置编译架构
    set_arch("riscv")
    -- 设置编译工具链
    set_toolchains("wch-riscv-gcc")
    -- 设置生成文件名
    set_filename("ch573.elf")
    -- 设置优化级别，smallest=-Os最小化代码优化
    if is_mode("release") then
        set_optimize("smallest")
    end
    -- 设置语言标准
    set_languages("gnu99", "cxx11")

    -- 添加宏定义
    if is_mode("debug") or is_mode("check") then
        add_defines("DEBUG")
    end
    -- U盘是否挂载USBhub下面，不挂载则定义
    add_defines("DISK_WITHOUT_USB_HUB")
    -- 是否使用U盘文件系统库，使用则定义
    add_defines("DISK_LIB_ENABLE")

    -- 添加C/C++编译选项
    add_cxflags(
        "-march=rv32imac",
        "-mabi=ilp32",
        "-mcmodel=medany",
        "-msmall-data-limit=8",
        "-mno-save-restore",
        "-fmessage-length=0",
        "-fsigned-char",
        "-ffunction-sections",
        "-fdata-sections",
        "-fno-common",
        "-Wunused"
    )
    if is_mode("debug") or is_mode("check") then
        add_cxflags("-g")
    end
    -- 添加汇编编译选项
    add_asflags(
        "-march=rv32imac",
        "-mabi=ilp32",
        "-mcmodel=medany",
        "-msmall-data-limit=8",
        "-mno-save-restore",
        "-fmessage-length=0",
        "-fsigned-char",
        "-ffunction-sections",
        "-fdata-sections",
        "-fno-common",
        "-Wunused",
        "-x assembler"
    )
    if is_mode("debug") or is_mode("check") then
        add_asflags("-g")
    end
    -- 添加静态链接选项
    add_ldflags(
        "-nostartfiles",
        "-Xlinker --gc-sections",
        "-Xlinker --print-memory-usage",
        "--specs=nano.specs",
        "-u _printf_float",
        "--specs=nosys.specs"
    )

    -- 添加SDK相关文件
        local sdk_path = "$(projectdir)/sdk"
        -- 添加链接库搜索目录
        add_linkdirs(sdk_path.."/StdPeriphDriver")
        add_linkdirs(sdk_path.."/USB_LIB")
        -- 添加链接库
        add_links("ISP573", "RV3UFI")
        -- 添加启动文件
        add_files(sdk_path.."/Startup/startup_CH573.S")
        -- 添加链接脚本
        add_files(sdk_path.."/Ld/Link.ld")
        -- 添加源文件
        add_files(sdk_path.."/**.c")
        -- 添加头文件搜索目录
        add_includedirs(sdk_path.."/RVMSIS")
        add_includedirs(sdk_path.."/StdPeriphDriver/inc")
        add_includedirs(sdk_path.."/USB_LIB")

    -- 添加项目相关文件
        local src_path = "$(projectdir)/src"
        -- 添加源文件
        add_files(src_path.."/**.c")
        -- 添加头文件搜索目录
        -- add_includedirs(src_path.."/inc")

    -- 加载时操作
    on_load(function (target)
        local map_file = string.format("%s/%s.map",
            target:targetdir(), target:name())
        target:add("ldflags", "-Wl,-Map,"..map_file)
    end)

    -- 构建后操作
    after_build(function (target)
        cprint(" ");
        cprint("${green}Compile finished!!! ${heavy_check_mark}")
        cprint("generating hex files...")
        os.exec("riscv-none-embed-objcopy -O ihex %s/%s %s/%s.hex",
            target:targetdir(), target:filename(), target:targetdir(), target:name())
        cprint("${green}Generate hex files ok!!! ${heavy_check_mark}")

        cprint(" ");
        os.exec("riscv-none-embed-size --format=berkeley %s/%s",
            target:targetdir(), target:filename())
        cprint(" ");
    end)

    -- 清理后操作
    after_clean(function (target)
        os.rm(target:targetdir().."/*")
    end)
target_end()

--
-- If you want to known more usage about xmake, please see https://xmake.io
--
-- ## FAQ
--
-- You can enter the project directory firstly before building project.
--
--   $ cd projectdir
--
-- 1. How to build project?
--
--   $ xmake
--
-- 2. How to configure project?
--
--   $ xmake f -p [macosx|linux|iphoneos ..] -a [x86_64|i386|arm64 ..] -m [debug|release]
--
-- 3. Where is the build output directory?
--
--   The default output directory is `./build` and you can configure the output directory.
--
--   $ xmake f -o outputdir
--   $ xmake
--
-- 4. How to run and debug target after building project?
--
--   $ xmake run [targetname]
--   $ xmake run -d [targetname]
--
-- 5. How to install target to the system directory or other output directory?
--
--   $ xmake install
--   $ xmake install -o installdir
--
-- 6. Add some frequently-used compilation flags in xmake.lua
--
-- @code
--    -- add debug and release modes
--    add_rules("mode.debug", "mode.release")
--
--    -- add macro defination
--    add_defines("NDEBUG", "_GNU_SOURCE=1")
--
--    -- set warning all as error
--    set_warnings("all", "error")
--
--    -- set language: c99, c++11
--    set_languages("c99", "c++11")
--
--    -- set optimization: none, faster, fastest, smallest
--    set_optimize("fastest")
--
--    -- add include search directories
--    add_includedirs("/usr/include", "/usr/local/include")
--
--    -- add link libraries and search directories
--    add_links("tbox")
--    add_linkdirs("/usr/local/lib", "/usr/lib")
--
--    -- add system link libraries
--    add_syslinks("z", "pthread")
--
--    -- add compilation and link flags
--    add_cxflags("-stdnolib", "-fno-strict-aliasing")
--    add_ldflags("-L/usr/local/lib", "-lpthread", {force = true})
--
-- @endcode
--

