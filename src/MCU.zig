const std = @import("std");

const Types = @import("./Types.zig");
const Transform = @import("./Transform.zig");
const Utils = @import("./Utility.zig");

const CompMatrices = [3][8][8]isize;
const EByE = [8][8]isize;

pub const MCU = struct {
    mcuCount: usize,
    qTables: [][]u16,
    dcDiff: [3]i32,
    block: [3][8][8]f32,
    idctCoeffs: [3][8][8]f32,

    pub fn init() MCU {
        return MCU{
            .mcuCount = 0,
            .qTables = &[_][]u16{},
            .dcDiff = .{ 0, 0, 0 },
            .block = undefined,
            .idctCoeffs = undefined,
        };
    }

    pub fn constructMCU(self: *MCU, compRLE: [3][]i32, qTables: [][]u16) void {
        self.qTables = qTables;
        self.mcuCount += 1;

        for (0..3) |compID| {
            var zzOrder: [64]i32 = .{0} ** 64;
            var j: i32 = -1;

            for (0..compRLE[compID].len - 2) |i| {
                if (compRLE[compID][i] == 0 and compRLE[compID][i + 1] == 0) break;
                j += compRLE[compID][i] + 1;
                zzOrder[j] = compRLE[compID][i + 1];
            }

            self.dcDiff[compID] += zzOrder[0];
            zzOrder[0] = self.dcDiff[compID];

            const qIndex = if (compID == 0) 0 else 1;
            for (0..64) |i| {
                zzOrder[i] *= @intCast(self.qTables[qIndex][i]);
            }

            for (0..64) |i| {
                const coords = self.zigZagToMatrix(i);
                self.block[compID][coords[0]][coords[1]] = @as(f32, zzOrder[i]);
            }
        }

        self.computeIDCT();
        self.performLevelShift();
        self.convertYCbCrToRGB();
    }

    fn zigZagToMatrix(index: usize) [2]usize {
        const zigzagOrder = [_][2]usize{
            // Zig-zag order mapping here...
        };
        return zigzagOrder[index];
    }

    fn computeIDCT(self: *MCU) void {
        for (0..3) |i| {
            for (0..8) |x| {
                for (0..8) |y| {
                    var sum: f32 = 0.0;

                    for (0..8) |u| {
                        for (0..8) |v| {
                            const cu = if (u == 0) 1.0 / std.math.sqrt(2.0) else 1.0;
                            const cv = if (v == 0) 1.0 / std.math.sqrt(2.0) else 1.0;

                            sum += cu * cv * self.block[i][u][v] *
                                std.math.cos((2 * @as(f32, x) + 1) * @as(f32, u) * std.math.pi / 16.0) *
                                std.math.cos((2 * @as(f32, y) + 1) * @as(f32, v) * std.math.pi / 16.0);
                        }
                    }

                    self.idctCoeffs[i][x][y] = 0.25 * sum;
                }
            }
        }
    }

    fn performLevelShift(self: *MCU) void {
        for (0..3) |i| {
            for (0..8) |y| {
                for (0..8) |x| {
                    self.block[i][y][x] = std.math.round(self.idctCoeffs[i][y][x]) + 128;
                }
            }
        }
    }

    fn convertYCbCrToRGB(self: *MCU) void {
        for (0..8) |x| {
            for (0..8) |y| {
                const Y = self.block[0][y][x];
                const Cb = self.block[1][y][x];
                const Cr = self.block[2][y][x];

                const R: u8 = @intCast(std.math.clamp(0, 255, @intCast(Y + 1.402 * (Cr - 128.0))));
                const G: u8 = @intCast(std.math.clamp(0, 255, @intCast(Y - 0.344136 * (Cb - 128.0) - 0.714136 * (Cr - 128.0))));
                const B: u8 = @intCast(std.math.clamp(0, 255, @intCast(Y + 1.772 * (Cb - 128.0))));

                self.block[0][y][x] = R;
                self.block[1][y][x] = G;
                self.block[2][y][x] = B;
            }
        }
    }
};
