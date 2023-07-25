use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use cairo_lib::data_structures::mmr::utils::{compute_root, get_height};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use traits::Into;
use result::Result;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

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

    // returns the new MMR root or an error
    fn append(ref self: MMR, element: felt252, peaks: Peaks) -> Result<felt252, felt252> {
        let computed_root = compute_root(self.last_pos.into(), peaks);
        if computed_root != self.root {
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
                if i == peaks.len() - 2 {
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

}
