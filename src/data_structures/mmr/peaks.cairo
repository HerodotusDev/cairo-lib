use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::compute_root;
use cairo_lib::utils::array::span_contains;

type Peaks = Span<felt252>;

#[generate_trait]
impl PeaksImpl of PeaksTrait {
    // @notice Bags the peaks (hashing them together)
    // @return The bagged peaks
    fn bag(self: Peaks) -> felt252 {
        if self.is_empty() {
            return 0;
        }

        let mut i = self.len() - 1;
        let mut bags = *self.at(i);

        if i == 0 {
            return bags;
        }

        loop {
            i -= 1;
            bags = PoseidonHasher::hash_double(*self.at(i), bags);

            if i == 0 {
                break bags;
            };
        }
    }

    // @notice Checks if the peaks are valid
    // @param last_pos The last position in the MMR
    // @param root The root of the MMR
    // @return True if the peaks are valid
    fn valid(self: Peaks, last_pos: usize, root: felt252) -> bool {
        let computed_root = compute_root(last_pos.into(), self);
        computed_root == root
    }

    // @notice Checks if the peaks contain a peak
    // @param peak The peak to check inclusion
    // @return True if the peaks contain the peak
    fn contains_peak(self: Peaks, peak: felt252) -> bool {
        span_contains(self, peak)
    }
}
