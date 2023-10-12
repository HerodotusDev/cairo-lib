use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use cairo_lib::data_structures::mmr::proof::{Proof, ProofTrait};
use cairo_lib::data_structures::mmr::utils::{
    compute_root, get_height, mmr_size_to_leaf_count, leaf_count_to_peaks_count, trailing_ones, get_peak_info
};
use cairo_lib::hashing::poseidon::PoseidonHasher;

// @notice Merkle Mountatin Range struct
#[derive(Drop, Clone, Serde, starknet::Store)]
struct MMR {
    root: felt252,
    last_pos: usize
}

impl MMRDefault of Default<MMR> {
    // @return MMR with last_pos 0 and root poseidon(0, 0)
    #[inline(always)]
    fn default() -> MMR {
        MMR { root: PoseidonHasher::hash_double(0, 0), last_pos: 0 }
    }
}

#[generate_trait]
impl MMRImpl of MMRTrait {
    // @notice Creates a new MMR
    // @param root The root of the MMR
    // @param last_pos The last position in the MMR
    // @return MMR with the given root and last_pos
    #[inline(always)]
    fn new(root: felt252, last_pos: usize) -> MMR {
        MMR { root, last_pos }
    }

    // @notice Appends an element to the MMR
    // @param hash The hashed element to append
    // @param peaks The peaks of the MMR
    // @return Result with the new root and new peaks of the MMR
    fn append(ref self: MMR, hash: felt252, peaks: Peaks) -> Result<(felt252, Peaks), felt252> {
        let leaf_count = mmr_size_to_leaf_count(self.last_pos);
        let peaks_count = peaks.len();

        if leaf_count_to_peaks_count(leaf_count) != peaks_count {
            return Result::Err('Invalid peaks count');
        }
        if !peaks.valid(self.last_pos, self.root) {
            return Result::Err('Invalid peaks');
        }

        self.last_pos += 1;

        let new_peaks_count = trailing_ones(leaf_count);
        let mut new_peak = hash;
        let mut i = 0;

        loop {
            if i == new_peaks_count {
                break ();
            }

            new_peak = PoseidonHasher::hash_double(*peaks.at(peaks.len() - i - 1), new_peak);

            i += 1;
            self.last_pos += 1;
        };

        let mut new_peaks = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == peaks_count - new_peaks_count {
                break ();
            }
            new_peaks.append(*peaks.at(i));

            i += 1;
        };
        new_peaks.append(new_peak);

        let new_root = compute_root(self.last_pos.into(), new_peaks.span());
        self.root = new_root;

        Result::Ok((new_root, new_peaks.span()))
    }

    // @notice Verifies a proof for an element in the MMR
    // @param index The index of the element in the MMR
    // @param hash The hash of the element
    // @param peaks The peaks of the MMR
    // @param proof The proof for the element
    // @return Result with true if the proof is valid, false otherwise
    fn verify_proof(
        self: @MMR, index: usize, hash: felt252, peaks: Peaks, proof: Proof
    ) -> Result<bool, felt252> {
        if !peaks.valid(*self.last_pos, *self.root) {
            return Result::Err('Invalid peaks');
        }
        let (peak_index, peak_height) = get_peak_info(*self.last_pos, index);

        if proof.len() != peak_height {
            return Result::Ok(false);
        }

        let peak = proof.compute_peak(index, hash);

        Result::Ok(*peaks.at(peak_index) == peak)
    }
}
