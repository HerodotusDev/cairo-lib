use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::compute_root;
use cairo_lib::data_structures::mmr::mmr::{MmrSize, MmrElement};
use cairo_lib::utils::array::span_contains;

// @notice Represents the peaks of the MMR
type Peaks = Span<MmrElement>;

#[generate_trait]
impl PeaksImpl of PeaksTrait {
    // @notice Bags the peaks (hashing them together)
    // @return The bagged peaks
    fn bag(self: Peaks) -> MmrElement {
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

    // @notice Checks if the peaks are valid for a given root
    // @param last_pos The last position in the MMR
    // @param root The root of the MMR
    // @return True if the peaks are valid
    fn valid(self: Peaks, last_pos: MmrSize, root: MmrElement) -> bool {
        let computed_root = compute_root(last_pos, self);
        computed_root == root
    }
}
