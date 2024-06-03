use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::mmr::{MmrSize, MmrElement};
use cairo_lib::data_structures::mmr::utils::get_height;
use cairo_lib::utils::bitwise::{left_shift, bit_length};
use cairo_lib::utils::math::pow;

// @notice Represents a proof of inclusion in a MMR
type Proof = Span<felt252>;


#[generate_trait]
impl ProofImpl of ProofTrait {
    // @notice Computes a peak of the Merkle Mountain Range (root of a subtree)
    // @param index Index of the element to start from
    // @param hash Hash of the element to start from
    // @return The root of the subtree
    fn compute_peak(self: Proof, index: MmrSize, hash: MmrElement) -> felt252 {
        // calculate direction array
        // direction[i] - whether the i-th node from the root is a left or a right child of its
        // parent
        let mut bits: MmrSize = bit_length(index);
        if self.len().into() + 1 > bits {
            bits = self.len().into() + 1;
        };

        let mut direction: Array<bool> = ArrayTrait::new();
        let mut p: MmrSize = 1;
        let mut q: MmrSize = pow(2, bits) - 1;

        loop {
            if p >= q {
                break ();
            }
            let m: MmrSize = (p + q) / 2;

            if index < m {
                q = m - 1;
                direction.append(false);
            } else {
                p = m;
                q = q - 1;
                direction.append(true);
            };
        };

        // find the root hash, starting from the leaf
        let mut current_index = index;
        let mut current_hash = hash;

        let mut i: usize = 0;
        let mut two_pow_i: MmrSize = 2;
        loop {
            if i == self.len() {
                break current_hash;
            }

            if *direction.at(direction.len() - i - 1) {
                // right child
                current_hash = PoseidonHasher::hash_double(*self.at(i), current_hash);

                current_index += 1;
            } else {
                // left child
                current_hash = PoseidonHasher::hash_double(current_hash, *self.at(i));

                current_index += two_pow_i;
            }

            i += 1;
            two_pow_i *= 2;
        }
    }
}
