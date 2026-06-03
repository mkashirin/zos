const io = @import("io.zig");

// We need to define a `MultiBootHeader` struct following the pattern from
// Header Magic Fields config, we need 3 fields:
// * `magic: i32` is the magic number identifying the header, which must
//   be the hexadecimal value 0x1BADB002;
// * `flags: i32` specifies features that the OS image requests or requires
//   from the boot loader;
// * `checksum: i32` is a 32-bit signed value which, when added to the other
//   magic fields (i.e. magic and flags), must have a 32-bit unsigned sum being
//   equal to zero.
const MultiBootHeader = extern struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const FLAGS: i32 = ALIGN | MEMINFO;
const MAGIC: i32 = 0x1BADB002;
const CHECKSUM: i32 = 0 -% (MAGIC +% FLAGS);

// There're 3 important notations for the `multiboot`:
// * `export` makes a function or variable externally visible in the
//   generated object file;
// * `align(4)` specifies that when a value of the type is loaded from or
//   stored to memory, the memory address must be evenly divisible by 4;
// * `linksection(".multiboot")` basically links the `multiboot` variable
//   with the `.multiboot` section in the linker script.
export var multiboot: MultiBootHeader align(4) linksection(".multiboot") = .{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = CHECKSUM,
};

// Now when the multiboot is set up, it is time to define an entry point
// (`_start`) to our kernel:
// * `callconv(.naked)` changes the calling convention of the function to
//   `.naked` so that it can be run on bare metal;
// * `noreturn` is a special keyword which states that function does not
//   return at all (every entry point to the OS is like that).
export fn _start() noreturn {
    // Inline volatile Assembly must be involved to call the exported
    // function, which would serve as a gateway to the runtime. Since it
    // is exported, we can just call it directly. After that, we disable any
    // maskable hardware interrupts on x86(_64).
    kmain();
    asm volatile ("cli");

    // Then the spin is acquired, even though it is not neccessary and `void`
    // can still be used as a return type for this `_start()` function.
    while (true) {}
    unreachable;
}

// This function gets called by `_start()` to provide a gateway to the runtime.
fn kmain() void {
    io.clearScreen();
    io.putMessage("Hello from ZOS!");
}
