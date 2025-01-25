const RGBComponents = enum { RED, GREEN, BLUE };

const Pixel = struct {
    comp: [3]i16 = .{ 0, 0, 0 },

    pub fn init(comp1: i16, comp2: i16, comp3: i16) Pixel {
        return Pixel{
            .comp = .{ comp1, comp2, comp3 },
        };
    }
};

const HuffmanTableItem = struct {
    first: isize,
    second: []u8,
};

const HuffmanTable = [16]HuffmanTableItem

const HT_DC = 0;
const HT_AC = 1;
const HT_Y = 0;
const HT_CBCR = 1;
