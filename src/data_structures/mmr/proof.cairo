use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::get_height;
use cairo_lib::utils::bitwise::left_shift;
use array::SpanTrait;
use traits::Into;
use debug::PrintTrait;

type Proof = Span<felt252>;

#[generate_trait]
impl ProofImpl of ProofTrait {
    // @notice Computes a peak of the Merkle Mountain Range (root of a subtree)
    // @param index Index of the element to start from
    // @param hash Hash of the element to start from
    // @return The root of the subtree
    fn compute_peak(self: Proof, index: usize, hash: felt252) -> felt252 {
        let mut current_hash = hash;
        let mut current_index = index;

        let mut i: usize = 0;
        loop {
            if i == self.len() {
                break current_hash;
            }

            let next_height = get_height(current_index + 1);
            if next_height > i {
                // right child
                current_hash = PoseidonHasher::hash_double(*self.at(i), current_hash);

                current_index += 1;
            } else {
                // left child
                current_hash = PoseidonHasher::hash_double(current_hash, *self.at(i));

                current_index += left_shift(2, i);
            }

            i += 1;
        }
    }
}
