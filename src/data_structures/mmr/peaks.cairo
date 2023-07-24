use array::SpanTrait;
use cairo_lib::hashing::poseidon::PoseidonHasher;

type Peaks = Span<felt252>;

#[generate_trait]
impl PeaksImpl of PeaksTrait {
    fn bag(self: Peaks) -> felt252 {
        let mut i = self.len() - 1;
        let mut bags = *self.at(i);
        loop {
            if i < 0 {
                break bags;
            }

            bags = PoseidonHasher::hash_double(*self.at(i), bags);
            i -= 1;
        }
    }
}
