use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use cairo_lib::data_structures::mmr::proof::{Proof, ProofTrait};
use cairo_lib::data_structures::mmr::utils::{compute_root, get_height};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use traits::{Into, Default};
use clone::Clone;
use result::Result;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

#[derive(Drop, Clone, Serde, starknet::Store)]
struct MMR {
    root: felt252,
    last_pos: usize
}

impl MMRDefault of Default<MMR> {
    #[inline(always)]
    fn default() -> MMR {
        MMR {
            root: PoseidonHasher::hash_double(0, 0),
            last_pos: 0
        }
    }
}

#[generate_trait]
impl MMRImpl of MMRTrait {
    fn new(root: felt252, last_pos: usize) -> MMR {
        MMR {
            root,
            last_pos
        }
    }

    // returns the new MMR root or an error
    fn append(ref self: MMR, element: felt252, peaks: Peaks) -> Result<felt252, felt252> {
        if !peaks.valid(self.last_pos, self.root) {
            return Result::Err('Invalid peaks');
        }

        self.last_pos += 1;
        let hash = PoseidonHasher::hash_double(element, self.last_pos.into());

        // TODO refactor this logic
        let mut peaks_arr = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i == peaks.len() {
                break ();
            }

            peaks_arr.append(*peaks.at(i));

            i += 1;
        };
        peaks_arr.append(hash);

        let mut height = 0;
        loop {
            if get_height(self.last_pos + 1) <= height {
                break ();
            }
            self.last_pos += 1;

            let mut peaks_span = peaks_arr.span();
            let right = peaks_span.pop_back().unwrap();
            let left = peaks_span.pop_back().unwrap();

            // TODO refactor this logic
            let mut new_peaks = ArrayTrait::new();
            i = 0;
            loop {
                if i == peaks_arr.len() - 2 {
                    break ();
                }

                new_peaks.append(*peaks_arr.at(i));

                i += 1;
            };

            let hash = PoseidonHasher::hash_double(*left, *right);
            let hash_index = PoseidonHasher::hash_double(self.last_pos.into(), hash);
            new_peaks.append(hash_index);
            peaks_arr = new_peaks;

            height += 1;
        };

        let new_root = compute_root(self.last_pos.into(), peaks_arr.span());
        self.root = new_root;

        return Result::Ok(new_root);
    }

    fn verify_proof(self: @MMR, index: usize, value: felt252, peaks: Peaks, proof: Proof) -> Result<bool, felt252> {
        if !peaks.valid(*self.last_pos, *self.root) {
            return Result::Err('Invalid peaks');
        }

        let peak = proof.compute_peak(index, value);
        Result::Ok(peaks.contains_peak(peak))
    }
}
