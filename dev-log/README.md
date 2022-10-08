## Developer Log for petOS
I thought it might be interesting to keep a track of my process as I am building up this OS. In future, if I decide to make this repo, might help other developers to start, and also it can help me to get back anytime and refresh my memory on the concepts.

### Day 1 - Getting into BIOS
Anytime a computer is started it looks for something that it can transfer control to, i.e. bootable sectors in the disks or anything similar to that.

- Now the question is, is something special about the bootable sector that the computer looks for?
Well both yes and no, yes the computer does look for something that helps it determine the boot sector and no it's nothing special except couple of bytes. Do keep in mind, I am building an OS for x86 so these might be different for different architecture. Anyhow in x86 the computer looks for 0x55aa at memory location 512 with some padding we will talk about this later.

Here we need a bit of assembly, luckily I have worked with assembly in the past and am very familiar with ASM code. And I believe ASM is one of the easiest languages out there along side python, it's just that it's conventions are bit different from other languages.

Code:
```asm
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa
```
- `jmp $` - In assembly, jmp is an instruction for the cpu to jump on an address, the address in this case is `$`, which means the current address. So in our code the CPU keeps jumping on the same address forever.
- `times 510-($-$$) db 0` - times as the name suggest is instructing the CPU to execute the following instruction `db 0`, `510-($-$$)` times. `db` stands for `define byte`, so this instruction will put a 0x00 at the address, and 510 - ($ - $$), means well $ means the current address and `$$` means the address of where the scope started, so in this case the beginning of the file.
- `db 0x55, 0xaa` - And lastly we have `db 0x55, 0xaa` it's basically defining two bytes i.e. 0x55 and 0xaa at the address, we can also write it as `dw 0xaa55`, but I like this more so we roll with this.

And that's it we just created a binary file with 510 bytes filled with zeroes and only two bytes at the end set to our magic number i.e. 0x55aa.

```bash
$ nasm -f bin boot.asm -o boot.bin
$ qemu-system-x86_64 boot.bin
```

> You should see a not very satisfying message in the qemu saying "Booting from hard disk."
So now our code is bootable and we got the control, but this is just the starting. We have a long way to go, but before that it would be nice if we get to play with the BIOS mode for a bit and have fun with it. And since we are running it in virtual machine, we can break it without worrying about destroying our machine.

> Let's print the legendary "Hello! momo" message.
Now there are multiple ways to do this, first we will look at the hard way.

```asm
mov ah, 0x0e
mov al, "H"
int 0x10
.
; (Repeat these 3 moves and ints to print each character)
.

jmp $       ; the legendary infinite loop

times 510-($-$$) db 0
db 0x55, 0xaa
```

First let's understand how and why we moving characters here and there and what is this `int` instruction. Before any of that we need to remind ourselvesthat we're in Real mode right now i.e. we are in 16-bit mode right now, so here the registers are a bit different. If you're familiar with the theory than you can skip this part and move forward. But for those who aren't, registers are basically like special buckets that are soldered into the CPU to handle its tasks. So if the CPU needs anything from the memory it first needs to load it from the memory and transfer them into these registers to perform tasks on them.
Now different modes have different registers, but not so much.
In 16-bit mode we have access to:- `ax`, `bx`, `cx`, `dx`, `sp`, `bp` and some more. (Google for more info)
In 32-bit mode we have access to:- `eax`, `ebx`, `ecx`, `edx` and so on.. with an extra `e` at the prefix, which means extended ax.
Similarly in 64-bit mode we have:- `rax`, `rbx` and so on..

Now, if we wanna print something in the BIOS mode, we need to first move the character into the `ax` register. But our code doesn't seems like so, actually it does.

All the registers have a high and low part to it, so `ax` has `ah` and `al`. So combining both will form our `ax` register.

- `mov ah, 0x0e` - Here we are simply moving `0x0e` to the high part of the `ax` register, now what is this special `0x0e` character. Well if you look at the ascii table, you will find `0x0e` is the character to shift out, so it basically tells the cursor to move to the right.
- `mov al, "H"` - Here we are moving our character to the low part of the `ax` register. Now our `ax` register contains both the shift out character in it's high part and the actual character in its low part.
- `int 0x80` - This is actually special to Real mode only, once we switch to the Protected mode i.e. to 32-bit. We wouldn't be using `int` instructions anymore. For now, we will work with this. `int` instructions stands for interrupt, it tells the CPU to stop whatever it is doing and shift the focus here. Next `0x10` is the Opcode for the CPU that tells it to print anything i.e. stored in the `ax` register.

> You should now see the legendary "Hello! momo" on the screen.

Pretty simple right, but printing characters like this is a very tedious task and if the programmer inside you is screaming that there is a violation happening here i.e. the code repitition than you're right now we will be looking at the simple way and do this using loops and conditional jumps.

If you're already familiar with assembly, it would be a good exercise for you to do this on your own. If you're not than what're you doing here, go learn ASM. Anyhow loops in assembly are very much similar `goto` statements in C, and there are some special instructions in assembly for conditional jumps.

```asm
[org 0x7c00]

mov ah, 0x0e
mov bx, ourString

printString:
    mov al, [bx]
    cmp al, 0
    je  stringEnded
    int 0x10
    inc bx
    jmp printString

endString:
    jmp $

ourString:
    db "Hello! momo", 0

times 510-($-$$) db 0
db 0x55, 0xaa
```

We're pretty much doing the same as earlier with some minimal changes, let me go through one by one.

- `[org 0x7c00]` - What the heck is this, well I encourage you to try running this with and without this line in your code. You would realise it is doing something important, well remember earlier in the post we talked about offset and here they are. For some reason in x86 the addresses are offsetted by `0x7c00` now I don't know why this particular number, but if you find any reason for this I'd love to hear it. Anyhow moving on, to perform successful jumps and some other voodoo magic with the strings we must offset our addresses by 0x7c00, that's what this instruction `org` is doing. It means origin, so we are instructing the CPU that the origin of this namespace starts at 0x7c00, so eventually offsetting everything by 0x7c00.

- `mov bx, ourString` - It is very straightforward, we are moving the address of ourString to `bx` register. Remember, `ourString` is the label to the address where the `ourString` starts, so right now our bx only has "H" in it.

- `mov al, [bx]` - This is also simple, except those square brackets it's assembly way of telling that don't move the value of bx to ax instead move what's stored in bx to ax. So here we have the letter "H" in ax.

- `cmp al, 0` - Here we are doing a compare, cmp stands for compare. We are comparing if the `al` is equal to 0.

- `je stringEnded` - je stands for jump if equal. So here we are telling the CPU, if al is equal to 0, jump to the label `stringEnded`, which in our case is the address just above our legendary infinite loop.

- `inc bx` - inc stands for increment, so we increment the value of bx means we `bx` and now our bx should hold the address to "e" and so on..

- `jmp printString` - jmp stands for jump. Here we are just jumping back to the top i.e. printString and repeating the process, till our `al` is equal to 0. And that's why we added a 0 at the end of our string, and that's how pretty much every program handles strings.

- `ourString: db "Hello! momo", 0` - Now there are two parts to this, first is the label `ourString`, as earlier we know db just spits out some data into the memory, to keep track of that address we add a label to that address. And secondly, why do we have `0` at the end. Well try running it without `0` at the end, OS is a mess right. It will make more sense later on, for now we are adding a 0x00 at the end of our string. In C, that's why we have `null-terminated strings` because at the end the compiler adds 0x00.

> And here we again have our legendary "Hello! momo" on the screen. Pretty cool right.

Here is one more opcodes for you to play with, `0x16` to wait for the user input from keyboard, it automatically stores the character into the `al` register so one less instruction to write. You can play with more opcodes and ascii characters. Refer to wikipedia and some good ascii table on the web for references.

### Exercise
Build a REPL.

That's it for Day 1, next day hopefully tomorrow we will finally be switching to 32-bit Protected mode and say goodbye to these fun interrupts, and finally we complete the first stage.
