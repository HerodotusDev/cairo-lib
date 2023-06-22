use array::SpanTrait;
use traits::TryInto;

type Bytes = Span<u8>;

impl BytesTryIntoU256 of TryInto<Bytes, u256> {
    fn try_into(self: Bytes) -> Option<u256> {
        if self.len() > 32 {
            return Option::None(());
        }
        Option::None(())
    }
}
