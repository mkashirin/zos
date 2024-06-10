// This is a freestanding x86 program, so we don't have any standard library.
// We need to define the VGA text mode buffer and the I/O ports manually.

// VGA text mode buffer many-item pointer.
const VGA_BUFFER = @as([*]volatile u16, @ptrFromInt(0xB8000));

// I/O ports for VGA.
const VGA_PORT: u16 = 0x3D4;
const VGA_DATA: u16 = 0x3D5;

// Function to write a byte to an I/O port.
fn outbw(port: u16, data: u8) void {
    asm volatile ("outb %[data], %[port]"
        :
        : [port] "{dx}" (port),
          [data] "{al}" (data),
    );
}

// Function to put a character into the VGA text mode buffer.
pub fn put_char(char: u8, index: usize) void {
    // Setting cursor position.
    outbw(VGA_PORT, 0x0F);
    outbw(VGA_DATA, 0x00);
    outbw(VGA_PORT, 0x0E);
    outbw(VGA_DATA, 0x00);

    // Put character.
    VGA_BUFFER[index] = @as(u16, char) | (@as(u16, 0x0F) << 8);
}
