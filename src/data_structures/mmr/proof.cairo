use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::get_height;
use cairo_lib::utils::bitwise::left_shift;
use array::SpanTrait;
use traits::Into;

type Proof = Span<felt252>;

#[generate_trait]
impl ProofImpl of ProofTrait {
    // @notice Computes a peak of the Merkle Mountain Range (root of a subtree)
    // @param index Index of the element to start from
    // @param value Value of the element to start from
    // @return The root of the subtree
    fn compute_peak(self: Proof, index: usize, value: felt252) -> felt252 {
        let mut hash = PoseidonHasher::hash_double(index.into(), value);

        let mut current_index = index;
        let mut i: usize = 0;
        loop {
            if i == self.len() {
                break hash;
            }

            let next_height = get_height(current_index + 1);
            if next_height > i {
                // right child
                let hashed = PoseidonHasher::hash_double(*self.at(i), hash);

                current_index += 1;
                hash = PoseidonHasher::hash_double(current_index.into(), hashed);
            } else {
                // left child
                let hashed = PoseidonHasher::hash_double(hash, *self.at(i));

                current_index += left_shift(2, i);
                hash = PoseidonHasher::hash_double(current_index.into(), hashed);
            }

            i += 1;
        }
    }
}
