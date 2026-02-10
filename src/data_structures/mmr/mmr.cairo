use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use cairo_lib::data_structures::mmr::proof::{Proof, ProofTrait};
use cairo_lib::data_structures::mmr::utils::{
    compute_root, get_height, mmr_size_to_leaf_count, leaf_count_to_peaks_count, trailing_ones,
    get_peak_info
};
use cairo_lib::hashing::poseidon::PoseidonHasher;

type MmrElement = felt252;
type MmrSize = u256;

// @notice Merkle Mountatin Range struct
#[derive(Drop, Clone, Serde, starknet::Store)]
struct MMR {
    root: MmrElement,
    last_pos: MmrSize
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
    fn new(root: MmrElement, last_pos: MmrSize) -> MMR {
        MMR { root, last_pos }
    }

    // @notice Appends an element to the MMR
    // @param hash The hashed element to append
    // @param peaks The peaks of the MMR
    // @return Result with the new root and new peaks of the MMR
    fn append(ref self: MMR, hash: MmrElement, peaks: Peaks) -> Result<(MmrElement, Peaks), felt252> {
        let leaf_count = mmr_size_to_leaf_count(self.last_pos);
        let peaks_count= peaks.len();

        if leaf_count_to_peaks_count(leaf_count) != peaks_count.into() {
            return Result::Err('Invalid peaks count');
        }
        if !peaks.valid(self.last_pos, self.root) {
            return Result::Err('Invalid peaks');
        }

        self.last_pos += 1;

        // number of new nodes = trailing_ones(leaf_count)
        // explanation: https://mmr.herodotus.dev/append
        let no_merged_peaks = trailing_ones(leaf_count);
        let no_preserved_peaks = peaks_count - no_merged_peaks;
        let mut preserved_peaks = peaks.slice(0, no_preserved_peaks);
        let mut merged_peaks = peaks.slice(no_preserved_peaks, no_merged_peaks);

        let mut last_peak = hash;
        loop {
            match merged_peaks.pop_back() {
                Option::Some(x) => { last_peak = PoseidonHasher::hash_double(*x, last_peak); },
                Option::None => { break; }
            };
            self.last_pos += 1;
        };

        let mut new_peaks = ArrayTrait::new();
        loop {
            match preserved_peaks.pop_front() {
                Option::Some(x) => { new_peaks.append(*x); },
                Option::None => { break; }
            };
        };
        new_peaks.append(last_peak);

        let new_root = compute_root(self.last_pos, new_peaks.span());
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
        self: @MMR, index: MmrSize, hash: MmrElement, peaks: Peaks, proof: Proof
    ) -> Result<bool, felt252> {
        let leaf_count = mmr_size_to_leaf_count(*self.last_pos);
        if leaf_count_to_peaks_count(leaf_count) != peaks.len().into() {
            return Result::Err('Invalid peaks count');
        }
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
