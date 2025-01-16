const std = @import("std");

pub fn matIndicesToZZOrder(row: isize, column: isize) isize {
    const matOrder = [8][8]isize{ .{ 0, 1, 5, 6, 14, 15, 27, 28 }, .{ 2, 4, 7, 13, 16, 26, 29, 42 }, .{ 3, 8, 12, 17, 25, 30, 41, 43 }, .{ 9, 11, 18, 24, 31, 40, 44, 53 }, .{ 10, 19, 23, 32, 39, 45, 52, 54 }, .{ 20, 22, 33, 38, 46, 51, 55, 60 }, .{ 21, 34, 37, 47, 50, 56, 59, 61 }, .{ 35, 36, 48, 49, 57, 58, 62, 63 } };
    return matOrder[row][column];
}
pub fn zzOrderToMatIndices(zzindex: isize) .{ isize, isize } {
    const zzorder =
        [_]isize{ .{ 0, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 2, 0 }, .{ 1, 1 }, .{ 0, 2 }, .{ 0, 3 }, .{ 1, 2 }, .{ 2, 1 }, .{ 3, 0 }, .{ 4, 0 }, .{ 3, 1 }, .{ 2, 2 }, .{ 1, 3 }, .{ 0, 4 }, .{ 0, 5 }, .{ 1, 4 }, .{ 2, 3 }, .{ 3, 2 }, .{ 4, 1 }, .{ 5, 0 }, .{ 6, 0 }, .{ 5, 1 }, .{ 4, 2 }, .{ 3, 3 }, .{ 2, 4 }, .{ 1, 5 }, .{ 0, 6 }, .{ 0, 7 }, .{ 1, 6 }, .{ 2, 5 }, .{ 3, 4 }, .{ 4, 3 }, .{ 5, 2 }, .{ 6, 1 }, .{ 7, 0 }, .{ 7, 1 }, .{ 6, 2 }, .{ 5, 3 }, .{ 4, 4 }, .{ 3, 5 }, .{ 2, 6 }, .{ 1, 7 }, .{ 2, 7 }, .{ 3, 6 }, .{ 4, 5 }, .{ 5, 4 }, .{ 6, 3 }, .{ 7, 2 }, .{ 7, 3 }, .{ 6, 4 }, .{ 5, 5 }, .{ 4, 6 }, .{ 3, 7 }, .{ 4, 7 }, .{ 5, 6 }, .{ 6, 5 }, .{ 7, 4 }, .{ 7, 5 }, .{ 6, 6 }, .{ 5, 7 }, .{ 6, 7 }, .{ 7, 6 }, .{ 7, 7 } };

    return zzorder[zzindex];
}

pub fn bitStringToValue(bit_string: []const u8) i16 {
    if (std.mem.eql(u8, bit_string, "")) return 0x0000;

    var value: i16 = 0x0000;

    const sign = bit_string[0];
    const factor = if (std.mem.eql(u8, sign, "0")) -1 else 1;

    for (bit_string, 0..) |char, idx| {
        if (std.mem.eql(u8, char, sign)) value += std.math.pow(i16, 2, bit_string.len - 1 - idx);
    }

    return factor * value;
}

pub fn getValueCategory(value: i16) i16 {
    if (value == 0x0000) return 0;
    return std.math.log2(@abs(value)) + 1;
}
