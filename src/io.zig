// This is a freestanding x86 program, so we don't have any standard library.
// We need to define the VGA text mode buffer and the I/O ports manually.

// VGA text mode buffer many-item pointer.
const VGA_BUFFER = @as([*]volatile u16, @ptrFromInt(0xB8000));

// I/O ports for VGA.
const VGA_PORT: u16 = 0x3D4;
const VGA_DATA: u16 = 0x3D5;

// Function to write a byte to an I/O port.
// * `"outb %[data], %[port]"` is the assembly instruction that is being
// executed. `outb` is an x86 instruction that sends the byte in the `al`
// register to the I/O port specified by the `dx` register.
// * The `:` after the assembly code is the list of output operands. Since
// `outb` does not produce any output, this list is empty.
// * The `: [port] "{dx}" (port), [data] "{al}" (data)` part is the list of
// input operands. It maps the Zig variables `port` and `data` to the assembly
// registers `dx` and `al`, respectively.
// * `[port] "{dx}" (port)` and `[data] "{al}" (data)` map the Zig variables
//`port` and `data` to `dx` and `al` registers in the assembly code
// respectively.
// *  maps the Zig variable `data` to the `al` register in
// the assembly code.
// The `outb` instruction is used to send data to an I/O port. The `al` register
// is used to specify the data to be sent, and the `dx` register is used to
// specify the I/O port number.
fn outbw(port: u16, data: u8) void {
    asm volatile ("outb %[data], %[port]"
        :
        : [port] "{dx}" (port),
          [data] "{al}" (data),
    );
}

// Function to put a character into the VGA text mode buffer.
pub fn put_char(char: u8, index: usize) void {
    outbw(VGA_PORT, 0x0F);
    outbw(VGA_DATA, 0x00);
    outbw(VGA_PORT, 0x0E);
    outbw(VGA_DATA, 0x00);

    // Put character at the specified index.
    VGA_BUFFER[index] = @as(u16, char) | (@as(u16, 0x0F) << 8);
}
