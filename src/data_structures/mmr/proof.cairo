use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::get_height;
use cairo_lib::utils::bitwise::left_shift;
use array::SpanTrait;
use traits::Into;
use array::ArrayTrait;
type Proof = Span<felt252>;
use cairo_lib::utils::bitwise::bit_length;
use cairo_lib::utils::math::pow;

#[generate_trait]
impl ProofImpl of ProofTrait {
    // @notice Computes a peak of the Merkle Mountain Range (root of a subtree)
    // @param index Index of the element to start from
    // @param value Value of the element to start from
    // @return The root of the subtree
    fn compute_peak(self: Proof, index: usize, value: felt252) -> felt252 {
        let mut hash = PoseidonHasher::hash_double(index.into(), value);

        let mut bits = bit_length(index);
        if self.len() + 1 > bits {
            bits = self.len() + 1;
        };

        let mut path = ArrayTrait::new();
        let mut p: usize = 1;
        let mut q: usize = pow(2, bits) - 1;

        loop {
            if p >= q {
                break ();
            }
            let m: usize = (p + q) / 2;

            if index < m {
                q = m - 1;
                path.append(0); // TODO: probably use booleans to save space
            } else {
                p = m;
                q = q - 1;
                path.append(1);
            };
        };

        let mut current_index = index;
        let mut i: usize = 0;
        loop {
            if i == self.len() {
                break hash;
            }

            if *path.at(path.len() - i - 1) == 1 {
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
