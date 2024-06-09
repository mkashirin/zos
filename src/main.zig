const terminal = @import("terminal.zig");

const Terminal = terminal.Terminal;

// We need to define a `MultiBootHeader` struct following the pattern from
// Header Magic Fields config, we need 3 fields:
// * `magic: i32` is the magic number identifying the header, which must
// be the hexadecimal value 0x1BADB002;
// * `flags: i32` specifies features that the OS image requests or requires
// of an boot loader;
// * `checksum: i32` is a 32-bit unsigned value which, when added to the
// other magic fields (i.e. magic and flags), must have a 32-bit unsigned sum
// of zero.
const MultiBootHeader = extern struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const FLAGS = ALIGN | MEMINFO;
const MAGIC = 0x1BADB002;

// There're 3 important notations for the `multiboot`:
// * `export` makes a function or variable externally visible in the
// generated object file;
// * `align(4)` specifies that when a value of the type is loaded from or
// stored to memory, the memory address must be evenly divisible by 4;
// * `linksection(".multiboot")` basically links the `multiboot` variable
// with the `.multiboot` section in the linker script.
export var multiboot align(4) linksection(".multiboot") = MultiBootHeader{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

// Now when the multiboot is set up, it is time to define an entry point
// (`_start`) to our kernel:
// * `callconv(.Naked)` changes the calling convention of the function to
// `.Naked` so that it can be run on bare metal;
// * `noreturn` is a special keyword which states that function does not
// return at all (every entry point to the OS is like that).
export fn _start() callconv(.Naked) noreturn {
    // asm volatile (
    //     \\ call *%[func_ptr]
    //     \\ ret
    //     :
    //     : [func_ptr] "r" (&putHello),
    //     : "memory"
    // );

    // TODO: Figure out a way to make a runtime call to `putHello()`.

    while (true) {}
}

fn putHello() callconv(.C) void {
    var term = Terminal.init();
    term.write("Hello, World!");
}
