use array::SpanTrait;
use traits::Into;
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::compute_root;
use cairo_lib::utils::array::span_contains;

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

    fn valid(self: Peaks, last_pos: usize, root: felt252) -> bool {
        let computed_root = compute_root(last_pos.into(), self);
        computed_root == root
    }

    fn contains_peak(self: Peaks, peak: felt252) -> bool {
        span_contains(self, peak)
    }
}
