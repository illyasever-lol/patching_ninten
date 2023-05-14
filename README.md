# Switch NSP 反编译教程
[![HitCount](https://img.shields.io/endpoint?label=浏览总量&url=https%3A%2F%2Fhits.dwyl.com%2Fxfangfang%2Fns-patching-example.json)](https://hits.dwyl.com/xfangfang/ns-patching-example.svg?style=flat-square)
[![HitCount](https://img.shields.io/endpoint?label=单独浏览&url=https%3A%2F%2Fhits.dwyl.com%2Fxfangfang%2Fns-patching-example.json?show=unique)](https://hits.dwyl.com/xfangfang/ns-patching-example.svg?style=flat-square&show=unique)

注1：仅供学习研究，风险自负   
注2：命令行面向 *nix 用户，部分操作 Windows 用户可以使用 GUI 来完成  
注3：本教程不针对某个应用，无法使用此项目直接完成反编译。
注4：参考 [How to patch Nintendo Switch Applications in IDA](https://gist.github.com/Slluxx/502e3c7d0ebe8608af2c74e8cafd01cb) 详细讲解各个步骤，满足程序员的好奇心。  

### 步骤简介

1. 解压 nsp 中的主程序
2. 反编译
3. 重新打包（可选）
4. 制作 ips / ips32 Patch（可选）

### 第一步 解压nsp安装包

关于如何 dump nsp安装包，或者如何解压，有多种方式，选择你习惯的方式即可，下面记录了我的操作流程。

```shell
# 1. 使用 nxdumptool 以默认参数导出所有nsp
# 2. 使用 Lockpick_RCM 备份 title.keys 和 prod.keys，放在项目根目录
# 3. 脚本中的 titlekey 从备份的 title.keys 中可以找到

# 请注意，解压脚本只用于记录hactool的各项功能，并不能实际运行，需要根据情况自行修改
./unpack.sh
```

在 Windows 上，你也可以使用支持 GUI 操作的 [NxFileViewer](https://github.com/Myster-Tee/NxFileViewer) 或者 [NSG Manager](http://www.ffhome.com/works/1814.html) 来更容易地做到相似的事。

如果只需要生成 patch 文件而不需要重新打包，那么只需要解压出 `exefs/main` 文件（主程序）即可。

> 关于 patch 文件的说明：大气层在运行应用时会去指定目录加载 `程序或游戏资源文件` 用来[替换游戏/应用内的原版文件](https://github.com/Atmosphere-NX/Atmosphere/blob/master/docs/components/modules/loader.md)  
> 如果不想重新打包，那么只需要将修改后的 main，直接放在内存卡 `atmosphere/contents/0000000000000000/exefs` （0...0 对应游戏/应用ID）目录下，大气层在运行时就会自动加载修改后的 main。  
> 对于其他一些游戏资源文件，可以放置于 romfs 下用来替换，还有一些其他的替换方式这里就不多谈了。

### 第二步 修改

前一步的解压脚本将解压得到的文件放置在了 `temp/data` 目录下。

1. 将nso格式的程序转为通用 elf，生成的 elf 路径是 `temp/data/exefs/main.elf`  

```shell
nx2elf temp/data/exefs/main
```

> nso 是 switch 专属的运行库格式，我们在这里将 nso 转为 elf，可以被 IDA 或者 Ghidra 正确识别，用于后面的反编译。当然也有插件可以正确地把 nso 直接加载进这两个软件，他们分别是 [loaders](https://github.com/reswitched/loaders) 和 [Ghidra-Switch-Loader](https://github.com/Adubbz/Ghidra-Switch-Loader)，但是这两个插件是为了能加载设计的，导出的时候还是比较麻烦的，所以这个教程不涉及插件的使用。


2. 使用 IDA 或者 Ghidra 等其他反编译程序修改 main.elf，保存在项目根目录  
请查阅 [ghidra_patching](ghidra_patching.md)

3. 将上一步修改后的 elf 转为 nso
```shell
elf2nso main.elf temp/data/exefs/main
```

前面说过了，只需要将修改后的 main，直接放在内存卡 `atmosphere/contents/0000000000000000/exefs` （0...0 对应游戏/应用ID）目录下，大气层在运行时就会自动加载修改后的 main。

### 第三步 重新打包（可选）

如果你很想打包成一个整体，那么可以使用 hacpack 来做到，你也可以使用 hacpack 在 Windows 下的 GUI 工具来完成。  

```shell
# 同样的，脚本只演示了 hacpack 的常用命令，需要修改这个脚本以适应具体的情况
./pack.sh
```

### 第四步 制作 ips / ips32 Patch（可选）

前面我们说大气层支持直接替换 main，还有一种方式是使用补丁文件在加载原版 main 文件前，动态地修改。

我们在前面生成了修改后的 main 文件，这里称之为 main_patched。首先我们需要将 原版main 与 main_patched 解压。

```shell
# 解压 nso 示例
hactool -t nso0 --uncompressed=main_uncompressed temp/data/exefs/main
```

> 默认nso是压缩的，大气层会在执行之前解压，并应用 patch，所以我们的 patch 是需要在解压的情况下生成的。

拿到了两个解压后的 nso 文件后（`main_uncompressed` 与 `main_patched_uncompressed`）就可以使用工具生成 patch。比如：[RomPatcher.js](https://www.marcrobledo.com/RomPatcher.js/)、[sips](https://github.com/leoetlino/sips) 等等，有的工具生成的是 ips32格式的补丁，有的生成的是 ips格式，对于简单的修改，用哪个格式都可以，对于复杂的修改，ips32会更好一些。

我们在解压原程序的时候，输出内容大致如下：

```shell
NSO0:
    Build Id:                       FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
    Sections:
        .text:                      00000000-00000000
        .rodata:                    00000000-00000000
        .rwdata:                    00000000-00000000
        .bss:                       00000000-00000000
Done!
```
我们取 `Build Id` 前40字节作为 ips 文件的文件名，也就是：`FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF.ips`。将这个文件放置在 `atmosphere/exefs_patches/any_name_you_want/` 目录下即可。

最后来说一说如何缩小 ips patch 的大小。前面的 `main_patched` 是在 main.elf 修改版的基础上直接生成的，他的头部（也就是包含了 nso 信息的头部）因为是独立生成的，所以和原版不同，这也就导致，我们生成的patch文件包含了nso头部的变动，但这个其实不需要修改，可以通过修改刚刚得到的ips来移除这部分的变动。

在这之前，就需要介绍 ips/ips32 格式，他们使用了相似的格式： HEADER + [OFFSET + SIZE + DATA]* + TAIL

<detail>

ips:

```shell
# 不包含换行、空格和省略号
PATCH
# 24位偏移 大小 数据
000000 0001 00
000000 0004 00000000
000000 0108 000000...
...
EOF
```

ips32:

```shell
# 不包含换行、空格和省略号
IPS32
# 32位偏移 大小 数据
00000000 0001 00
00000000 0004 00000000
00000000 0108 000000...
...
EEOF
```

</detail>

看明白格式之后，做修改就很容易了。当然，依赖“肉人”修改二进制来缩小大小有点太消耗时间了，你也可以使用 [IPSwitch](https://github.com/3096/ipswitch) 来更好且更易阅读地生成 patch。


# 参考链接
Great thanks to Slluxx's Youtube patch example: [How to patch Nintendo Switch Applications in IDA](https://gist.github.com/Slluxx/502e3c7d0ebe8608af2c74e8cafd01cb)  
[nxdumptool](https://github.com/DarkMatterCore/nxdumptool)  
[NxFileViewer](https://github.com/Myster-Tee/NxFileViewer)  
[NSG Manager](http://www.ffhome.com/works/1814.html)  
[hactool](https://github.com/SciresM/hactool)  
[nx2elf](https://github.com/shuffle2/nx2elf)  
[switch-tools/elf2nso](https://github.com/switchbrew/switch-tools)  
[hacPack](https://github.com/The-4n/hacPack)  
[ghidra](https://github.com/NationalSecurityAgency/ghidra)  
[RomPatcher.js](https://www.marcrobledo.com/RomPatcher.js/)  
[sips](https://github.com/leoetlino/sips)  
[IPSwitch](https://github.com/3096/ipswitch)  
