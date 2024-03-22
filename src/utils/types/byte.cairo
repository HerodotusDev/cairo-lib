// @notice Represents a single byte
type Byte = u8;

#[generate_trait]
impl ByteImpl of ByteTrait {
    // @notice Extracts the high and low nibbles from a byte
    // @return (high, low), example: 0xab -> (0xa, 0xb)
    fn extract_nibbles(self: Byte) -> (Byte, Byte) {
        let (high, low) = DivRem::div_rem(
            self, TryInto::<Byte, NonZero<Byte>>::try_into(16).unwrap()
        );
        (high, low)
    }
}

