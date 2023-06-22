use cairo_lib::utils::bitwise::left_shift;
use array::SpanTrait;
use traits::{TryInto, Into};

type Bytes = Span<u8>;

impl BytesTryIntoU256 of TryInto<Bytes, u256> {
    fn try_into(self: Bytes) -> Option<u256> {
        let len = self.len();
        if len > 32 {
            return Option::None(());
        }

        let mut result: u256 = 0;
        let mut i: usize = 0;
        loop {
            if i >= len {
                break ();
            }
            let byte: u256 = (*self.at(i)).into();
            result += left_shift(byte, 8 * (31 - i.into()));
        };

        Option::Some(result)
    }
}
