use core::result::ResultTrait;
use clone::Clone;
use traits::AddEq;
use traits::{Into, TryInto};
use option::OptionTrait;
use array::{ArrayTrait, SpanTrait};
use debug::PrintTrait;
use cairo_lib::utils::array::{array_contains};
use cairo_lib::utils::bitwise::{left_shift, bit_length};
use cairo_lib::hashing::poseidon::PoseidonHasher;

#[derive(Drop)]
struct StatelessMmr {}

/// StatelessMmr implementation.
#[generate_trait]
impl StatelessMmrImpl of StatelessMmrTrait {
    /// Create a new stateless merkle mountain range instance.
    fn new() -> StatelessMmr {
        StatelessMmr {}
    }

    /// Compute the bagging of a given peaks. (Bagging == Hasing all the peaks from the last one to the first one)
    /// # Arguments
    /// * `peaks` - The current list of peaks.
    /// # Returns
    /// The bagged value of the peaks.
    fn bag_peaks(peaks: Span<felt252>) -> Result<felt252, felt252> {
        let peaks_len = peaks.len();
        if peaks_len == 0 {
            return Result::Err('ERR_INPUT_SHORT');
        }
        if peaks_len == 1 {
            return Result::Ok(*peaks.at(0));
        }

        let mut root = PoseidonHasher::double_hash(*peaks.at(peaks_len - 2), *peaks.at(peaks_len - 1));

        if peaks_len == 2 {
            return Result::Ok(root);
        }

        let mut i = peaks_len - 3;
        let mut k = 0;
        loop {
            root = PoseidonHasher::double_hash(*peaks.at(i - k), root);
            if k + 3 == peaks_len {
                break ();
            };
            k += 1;
        };
        return Result::Ok(root);
    }

    /// Compute the root of a given peaks.
    /// # Arguments
    /// * `peaks` - The current list of peaks.
    /// * `size` - The size of tree
    /// # Returns
    /// Root value of the tree.
    fn compute_root(peaks: Span<felt252>, size: felt252) -> Result<felt252, felt252> {
        let bagged_peaks = StatelessMmrTrait::bag_peaks(peaks);
        let root = PoseidonHasher::hash_double(size, bagged_peaks.unwrap());
        return Result::Ok(root);
    }

    /// Compute the tree height of a given index
    /// # Arguments
    /// * `index` - Index of the element.
    /// # Returns
    /// The height of the tree.
    fn height(index: u128) -> Result<u128, felt252> {
        if index == 0 {
            return Result::Err(0);
        }
        assert(index > 0, 'ERR_INDEX_OUT_OF_BOUNDS');
        let bits = bit_length(index);
        let ones = left_shift(1, bits) - 1;
        if !(index == ones) {
            let shifted = left_shift(1, bits - 1);
            let shifted_index = (index - (shifted - 1));
            let rec_height = StatelessMmrTrait::height(shifted_index);
            return rec_height;
        }
        return Result::Ok(bits - 1);
    }

    /// Append a new element to the MMR.
    /// # Arguments
    /// * `element` - The element to append.
    /// * `peaks` - The current list of peaks.
    /// * `last_elements_count` - The number of elements in the tree.
    /// * `last_root` - The root of the tree.
    /// # Returns
    /// The updated number of elements, the updated root and the updated list of peaks.
    fn append(
        ref self: StatelessMmr,
        element: felt252,
        peaks: Array<felt252>,
        last_elements_count: felt252,
        last_root: felt252
    ) -> (felt252, felt252, Array<felt252>) {
        let (updated_elements_count, new_root, new_peaks) = do_append(
            element, peaks, last_elements_count, last_root
        );
        return (updated_elements_count, new_root, new_peaks);
    }

    /// Append multiple elements to the MMR.
    /// # Arguments
    /// * `elements` - The elements to append.
    /// * `peaks` - The current list of peaks.
    /// * `last_elements_count` - The number of elements in the tree.
    /// * `last_root` - The root of the tree.
    /// # Returns
    /// The updated number of elements, the updated root and the updated list of peaks.
    fn multi_append(
        ref self: StatelessMmr,
        elements: Array<felt252>,
        peaks: Array<felt252>,
        last_elements_count: felt252,
        last_root: felt252
    ) -> (felt252, felt252, Array<felt252>) {
        let mut elements_count = last_elements_count;
        let mut root = last_root;
        let mut updated_peaks = peaks;
        let mut i = 0;
        loop {
            if i == elements.len() {
                break ();
            };
            let (elements_count_temp, root_temp, updated_peaks_temp) = do_append(
                *elements.at(i), updated_peaks, elements_count, root
            );
            elements_count = elements_count_temp;
            root = root_temp;
            updated_peaks = updated_peaks_temp;
            i += 1;
        };

        return (elements_count, root, updated_peaks);
    }

    /// Verify a proof.
    /// # Arguments
    /// * `index` - Index of the element.
    /// * `value` - Value of the element.
    /// * `proof` - The proof to verify.
    /// * `peaks` - The current list of peaks.
    /// * `elements_count` - The number of elements in the tree.
    /// * `root` - The root of the tree.
    /// # Returns
    /// Nothing if the proof is valid, an error otherwise.
    fn verify_proof(
        ref self: StatelessMmr,
        index: u128,
        value: felt252,
        proof: Array<felt252>,
        peaks: Array<felt252>,
        elements_count: felt252,
        root: felt252
    ) -> Result<bool, felt252> {
        let elements_count_u128: u128 = elements_count.try_into().unwrap();

        if index > elements_count_u128 {
            return Result::Err('ERR_INDEX_OUT_OF_BOUNDS');
        }

        let computed_root = StatelessMmrTrait::compute_root(peaks.span(), elements_count).unwrap();

        if !(root == computed_root) {
            return Result::Err('ERR_ROOT_MISMATCH');
        }

        let index_felt: felt252 = index.into();
        let hash = PoseidonHasher::double_hash(index_felt, value);
        let top_peak = get_proof_top_peak(0, hash, index, proof).unwrap();
        let is_valid = array_contains(top_peak, peaks.span());

        return Result::Ok(is_valid);
    }
}


fn get_proof_top_peak(
    mut height: u128, mut hash: felt252, mut elements_count: u128, proof: Array<felt252>
) -> Result<felt252, felt252> {
    let mut i = 0;
    let mut elements_count_felt: felt252 = elements_count.into();
    let mut current_sibling = 0;
    let mut next_height = 0;
    let mut is_higher = false;
    let mut hashed = 0;
    let mut parent_hash = 0;
    loop {
        if i == proof.len() {
            break ();
        };
        current_sibling = *proof.at(i);
        next_height = StatelessMmrTrait::height(elements_count + 1).unwrap();
        if next_height >= height + 1 {
            is_higher = true;
        } else {
            is_higher = false;
        };
        if is_higher {
            hashed = PoseidonHasher::double_hash(current_sibling, hash);
            elements_count = elements_count + 1;
        } else {
            hashed = PoseidonHasher::double_hash(hash, current_sibling);
            elements_count = elements_count + left_shift(height, 2);
        };
        elements_count_felt = elements_count.into();
        parent_hash = PoseidonHasher::double_hash(elements_count_felt, hashed);
        hash = parent_hash;
        height = height + 1;
        i = i + 1;
    };
    return Result::Ok(hash);
}
fn do_append(
    elem: felt252, mut peaks: Array<felt252>, last_elements_count: felt252, last_root: felt252
) -> (felt252, felt252, Array<felt252>) {
    let elements_count = last_elements_count + 1;
    if last_elements_count == 0 {
        let root0 = PoseidonHasher::double_hash(1, elem);
        let first_root = PoseidonHasher::double_hash(1, root0);
        let mut new_peaks: Array<felt252> = Default::default();
        new_peaks.append(root0);
        return (elements_count, first_root, new_peaks);
    }
    let computed_root = StatelessMmrTrait::compute_root(peaks.span(), last_elements_count).unwrap();
    assert(last_root == computed_root, 'ERR_ROOT_MISMATCH');
    let hash = PoseidonHasher::double_hash(elements_count, elem);
    peaks.append(hash);
    let (updated_peaks, updated_elements_count) = append_rec(0, peaks, elements_count);
    let new_root = StatelessMmrTrait::compute_root(updated_peaks.span(), updated_elements_count)
        .unwrap();
    return (updated_elements_count, new_root, updated_peaks);
}

fn append_rec(
    h: felt252, peaks: Array<felt252>, last_elements_count: felt252
) -> (Array<felt252>, felt252) {
    let elements_count = last_elements_count;
    let elements_count_u128: u128 = last_elements_count.try_into().unwrap();
    let next_height = StatelessMmrTrait::height(elements_count_u128 + 1).unwrap();
    let h_u128: u128 = h.try_into().unwrap();
    let mut is_higher = false;
    if h_u128 + 1 <= next_height {
        is_higher = true;
    }
    let mut peaks_len = peaks.len();
    if is_higher {
        let elements_count = elements_count + 1;

        let right_hash = peaks.at(peaks_len - 1);
        let left_hash = peaks.at(peaks_len - 2);
        peaks_len = peaks_len - 2;

        let hash = PoseidonHasher::double_hash(*left_hash, *right_hash);
        let parent_hash = PoseidonHasher::double_hash(elements_count, hash);

        let mut merged_peaks: Array<felt252> = Default::default();
        let mut i = 0;
        loop {
            if i == peaks_len {
                break ();
            };
            merged_peaks.append(*peaks.at(i));
            i = i + 1;
        };
        merged_peaks.append(parent_hash);
        return append_rec(h + 1, merged_peaks, elements_count);
    }

    return (peaks, elements_count);
}

fn multi_append_rec(
    elems: Array<felt252>, mut peaks: Array<felt252>, last_pos: felt252, last_root: felt252
) -> (felt252, felt252) {
    let pos = last_pos + 1;
    if last_pos == 0 {
        let root0 = PoseidonHasher::double_hash(1, *elems.at(0));
        let root = PoseidonHasher::double_hash(1, root0);
        return (pos, root);
    }
    let compute_root = StatelessMmrTrait::compute_root(peaks.span(), last_pos).unwrap();
    assert(last_root == compute_root, 'ERR_ROOT_MISMATCH');

    let hash = PoseidonHasher::double_hash(pos, *elems.at(0));

    peaks.append(pos);
    assert(*peaks.at(peaks.len()) == hash, 'ERR_PEAK_HASH_MISMATCH');

    let (peaks, new_pos) = append_rec(0, peaks, pos);
    let new_root = StatelessMmrTrait::compute_root(peaks.span(), new_pos).unwrap();

    let mut copy_elems = elems;
    copy_elems.pop_front();

    if copy_elems.len() == 0 {
        return (new_pos, new_root);
    }

    return multi_append_rec(copy_elems, peaks, new_pos, new_root);
}

