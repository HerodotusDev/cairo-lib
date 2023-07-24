use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
//use cairo_lib::hashing::poseidon::PoseidonHasher;

struct MMR {
    root: felt252,
    last_pos: usize
}

#[generate_trait]
impl MMRImpl of MMRTrait {
    fn new() -> MMR {
        MMR {
            root: 0,
            last_pos: 0
        }
    }
}
