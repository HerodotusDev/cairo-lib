use traits::{Into, TryInto};
use option::OptionTrait;
use cairo_lib::utils::bitwise::right_shift;

type Byte = u8;

#[generate_trait]
impl ByteImpl of ByteTrait {
    fn extract_nibbles(self: Byte) -> (Byte, Byte) {
        // TODO fix all hte conversions. Bitwise AND only supported for u128 and u256 :(
        // (next compiler version already supports)
        let masked = self.into() & 0xf0_u128;
        let high = right_shift(masked, 4);
        let low = self.into() & 0x0f_u128;

        (high.try_into().unwrap(), low.try_into().unwrap())
    }
}

