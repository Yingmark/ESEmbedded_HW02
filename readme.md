HW02 作業
===
## 1. 作業HW02_題目
1. 修改main.s以觀察`push`和`pop`指令。
2. 指令`push`和 `pop`中的暫存器順序是否會影響執行結果。
3. 指令`push`和`pop`動作說明。

## 2. 實驗步驟
1. 先將資料夾gnu-mcu-eclipse-qemu完整複製到ESEmbedded_HW02_Example資料夾中

2. 根據 http://www.nc.es.ncku.edu.tw/course/embedded/02/ - Processor Core Register Summary 敘述

    1. ARM Cortex-M4 處理器具有 32bits 暫存器
	* 13個一般暫存器, 其中R0-R7為低位元暫存器, R8-R12為高位元暫存器。
	* R13 為 Stack Pointer(SP)分`SP_process`和`SP_main`.
	* R14 為 Link Register(LR).
	* R15 為 Program Counter(PC).
	* XPSR 為 Special-purpose Program Status Registers.
    2. `push`和`pop`都使用 R13暫存器作為基址堆疊操作。
    3. `push`和`pop`差異性：
	 `push`指令, 舉例`push {r0}`時, 把`r0`放入`R13`暫存器當中, 而每放入一次Stack Pointer - 4bytes.
	 `pop`指令, 舉例`pop {r0}`時, 從`R13`取出資料放入`r0`當中, 而每取出一次Stack Pointer + 4bytes.

![](https://github.com/Yingmark/ESEmbedded_HW02_Example/img-folder/push_pop.jpg)

3. 在測試程式時, 目標指令`push {r0, r1, r2}`及指令`push{r2, r0, r1}`是否有相同行為,發現在`make`時會發生錯誤,
因此執行`push`指令時, 需要按照先後順序排列。

![](https://github.com/Yingmark/ESEmbedded_HW02_Example/img-folder/error_make.jpg)

4. 設計測試程式 main.s ，從 _start 開始後依序執行`movs`指令的搬移，目標觀看指令`push {r0, r1, r2}`觀看哪個暫存器先行壓入堆棧中。

main.s:
```assembly
_start:
	movs r0, #100
	movs r1, #50
	mov  r2, #102

	push {r0, r1, r2}

	pop {r3}
	pop {r4}
	pop {r5}

	b	label01

label01:
	nop
	bl	sleep

sleep:
	nop
	b	.
```

4. 將 main.s 編譯並以 qemu 模擬， `$ make clean`, `$ make`, `$ make qemu`
開啟另一 Terminal 連線 `$ arm-none-eabi-gdb` ，再輸入 `target remote localhost:1234` 連接，輸入兩次的 `ctrl + x` 再輸入 `2`, 開啟 Register 以及指令，並且輸入 `si` 單步執行觀察。

當未開始時, sp 為 `0x20000100`，其他並無變化。

![](https://github.com/Yingmark/ESEmbedded_HW02_Example/img-folder/01.png)

當執行`push {r0, r1, r2}`時, sp為`0x200000f4`, 每放入一次Stack Pointer位置減4bytes。

![](https://github.com/Yingmark/ESEmbedded_HW02_Example/img-folder/02.png)

而執行`pop {r3}`, `pop {r4}`, `pop {r5}`時, 資料依序從取出。

![](https://github.com/Yingmark/ESEmbedded_HW02_Example/img-folder/04.png)

## 3. 結果與討論
1. 上述針對`push`, `pop`指令進行說明, 舉例執行`push {r0, r1, r2}`指令時, 會先把`r2`暫存器存入, 再來
依序`r1`->`r0`; 而取出時執行指令`pop {r3}`, 符合先進後出, 先`push {r0}`取出至`pop {r3}`, 依序將`push {r1}`
取至`pop {r4}`, `push {r2}`取至`pop {r5}`。
2. 指令`push`等同於`str rx, [sp, #-4]!`.
3. 指令`pop` 等同於`ldr rx, [sp], #4`.
