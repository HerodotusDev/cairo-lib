// @notice Represents a single byte
pub type Byte = u8;

#[generate_trait]
pub impl ByteImpl of ByteTrait {
    // @notice Extracts the high and low nibbles from a byte
    // @return (high, low), example: 0xab -> (0xa, 0xb)
    fn extract_nibbles(self: Byte) -> (Byte, Byte) {
        let masked = self & 0xf0;
        // right shift by 4 bits
        let high = masked / 16;
        let low = self & 0x0f;

        (high, low)
    }
}

