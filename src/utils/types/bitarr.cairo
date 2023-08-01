use array::SpanTrait;
use traits::TryInto;

type BitArr = Span<bool>;

impl BitArrTryIntoFelt252 of TryInto<BitArr, felt252> {
    fn try_into(self: BitArr) -> Option<felt252> {
        if self.len() > 252 {
            return Option::None(());
        }
        let mut res = 0;
        let mut i: usize = 0;
        loop {
            if i == self.len() {
                break Option::Some(res);
            }

            let mut bit  = 0;
            if *self.at(i) {
                bit = 1;
            }

            res = res * 2 + bit;

            i += 1;
        }
    }
}
