const std = @import("std");

// Since we're using 16-bit terminal, 16 colors needed.
const Color = enum(u8) {
    black,
    blue,
    green,
    cyan,
    red,
    magenta,
    brown,
    light_grey,
    dark_grey,
    light_blue,
    light_green,
    light_cyan,
    light_red,
    light_magenta,
    light_brown,
    white,
};
const WIDTH = 80;
const HEIGHT = 25;

// Foreground | background color.
fn vgaEntryColor(foreground: Color, background: Color) u8 {
    // This will build the byte representing the color.
    return @intFromEnum(foreground) | (@intFromEnum(background) << 4);
}

fn vgaEntry(uchar: u8, color: u8) u16 {
    const bcolor: u16 = color;

    // This will build the 2 bytes representing the printable caracter
    // with `entryColor()`.
    return uchar | (bcolor << 8);
}

pub const Terminal = struct {
    // We are going to keep track of the row and column the cursor would be
    // pointing at.
    row: usize = 0,
    column: usize = 0,
    color: u8 = vgaEntryColor(Color.light_grey, Color.black),
    // Also we are going to initialize the buffer that is responsible for
    // outputting the text on the screen at the x86-specific address.
    buffer: [*]volatile u16 = @ptrFromInt(0xB8000),
    const Self = @This();

    // Initialize the terminal instance.
    // (You really should NOT do this more than once.)
    pub fn init() Self {
        var new: Self = .{};
        var h: usize = 0;
        while (h < HEIGHT) : (h += 1) {
            var w: usize = 0;
            while (w < WIDTH) : (w += 1) {
                new.putCharAt(' ', new.color, w, h);
            }
        }
        return new;
    }

    fn setColor(self: *Self, new_color: u8) void {
        self.color = new_color;
    }

    // Put the character at a specific position with particular coloring.
    fn putCharAt(
        self: *Self,
        char: u8,
        new_color: u8,
        w: usize,
        h: usize,
    ) void {
        const index = h * WIDTH + w;

        // Here we are actually writing to the screen output buffer.
        self.buffer[index] = vgaEntry(char, new_color);
    }

    // Put character and change the cursor postition.
    fn putChar(self: *Self, char: u8) void {
        if (char == '\n') {
            self.column = 0;
            self.row += 1;
            if (self.row == HEIGHT)
                self.row = 0;
        } else {
            self.putCharAt(char, self.color, self.column, self.row);
            self.column += 1;
            if (self.column == WIDTH) {
                self.column = 0;
                self.row += 1;
                if (self.row == HEIGHT)
                    self.row = 0;
            }
        }
    }

    // Write the data to the screen.
    pub fn write(self: *Self, data: []const u8) void {
        for (data) |char|
            self.putChar(char);
    }
};
