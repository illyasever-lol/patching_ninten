# 反编译

你可以使用任何一个顺手的反编译工具，这里以 [Ghidra](https://github.com/NationalSecurityAgency/ghidra) 为例。

我们参考 [How to patch Nintendo Switch Applications in IDA](https://github.com/xfangfang/ns-patching-example) 的教程，简单地以去除账号验证为例。  
有些软件打开时会验证任天堂的账号是否可用，一个已经被ban的，或者屏蔽了任天堂服务器的设备就会报错。解决思路很简单，我们可以直接不调用函数，或者不处理返回值报错。

### 流程

1. 打开 main.elf(aarch64 小端)，反编译。
> 任天堂的SDK中有很多关于 `account` 相关的函数，但并不是所有函数都有进行联网检查，我们只需要把做了联网检查的函数调用修改一下即可。因为咱们拿不到SDK的说明，所以只能猜测哪些函数做了检查，比如 `LoadNetworkServiceAccountIdTokenCache` 就是其中之一。

2. Ghidra 分析完成后，在左侧 `Symbol Tree` 搜索 `LoadNetworkServiceAccountIdTokenCache`，选中后点击左下角 `Function Call Tree` 中的 `Icomming Calls` 找到调用他的函数。

3. 在刚刚找到的函数中，找到调用 `nn::account::LoadNetworkServiceAccountIdTokenCache` 所在的位置，这就是我们需要修改的内容。往往这种联网验证不只有一处，可以根据情况搜索 account，查看还有哪些需要修改，这里就不过多讲解了。

4. 通过查看伪代码，可以发现，`nn::account::LoadNetworkServiceAccountIdTokenCache` 函数的返回值如果是非 0 的，就会报错。可以修改的方式有很多，比如不去调用这个函数，直接把固定的0填写到返回值应该在的寄存器内，也可以简单的将判断函数返回值是否为 0 的代码取反（比如 cbnz 改为 cbz，或者 cbz 改为 cbnz。这里 cb*z 是判断跳转的汇编语句）这样在检查报错时就不弹出提示。  
在 Ghidra 中，选择要改动的指令，右键选择 `Patch Instructoin` 即可修改
