// This is a freestanding x86 program, so we don't have any standard library.
// We need to define the VGA text mode buffer and the I/O ports manually.

// VGA text mode buffer many-item pointer.
const VGA_BUFFER: [*]volatile u16 = @ptrFromInt(0xB8000);
const VGA_BUFFER_LEN = 25 * 80;

// I/O ports for VGA.
const VGA_PORT: u16 = 0x3D4;
const VGA_DATA: u16 = 0x3D5;

// Colors
const Color = enum(u8) {
    black,
    blue,
    green,
    cyan,
    red,
    magenta,
    brown,
    lightgray,
    darkgray,
    lightblue,
    lightgreen,
    lightcyan,
    lightred,
    lightmagenta,
    yellow,
    white,
};

inline fn makeAttr(bg: Color, fg: Color) u8 {
    return (@intFromEnum(bg) << 4) | @intFromEnum(fg);
}

inline fn fmt(attr: u8, char: u8) u16 {
    return (@as(u16, @intCast(attr)) << 8) | @as(u16, @intCast(char));
}

pub inline fn clearScreen() void {
    for (0..VGA_BUFFER_LEN) |i| VGA_BUFFER[i] = 0x0;
}

pub fn putMessage(message: []const u8) void {
    for (0..message.len) |i| {
        VGA_BUFFER[i] = fmt(makeAttr(.blue, .white), message[i]);
    }
}
