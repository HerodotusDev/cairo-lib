use clone::Clone;
use traits::AddEq;
use traits::{Into, TryInto};
use option::OptionTrait;
use array::{ArrayTrait, SpanTrait};
use debug::PrintTrait;
use math::Oneable;
use zeroable::Zeroable;
use cairo_lib::utils::bitwise::{left_shift, bit_length};
use cairo_lib::hashing::hasher::Hasher;

/// StatelessMMR representation.
#[derive(Drop)]
struct StatelessMmr<T> {
    root: T,
    elements_count: usize,
}

// Need Generic type change method
extern fn usize_to_T<T>(a: usize) -> T nopanic;

impl IUsizeIntoT<T> of Into<usize, T> {
    fn into(self: usize) -> T {
        usize_to_T(self)
    }
}

/// StatelessMmr implementatizon.
#[generate_trait]
impl StatelessMmrImpl<
    T,
    H,
    impl TDrop: Drop<T>,
    impl TCopy: Copy<T>,
    impl TPartialEq: PartialEq<T>,
    impl HHasher: Hasher<T, T>,
    impl HDrop: Drop<H>
> of StatelessMmrTrait<T, H> {
    /// Create a new stateless merkle mountain range instance.
    #[inline(always)]
    fn new(root: T, elements_count: usize) -> StatelessMmr<T> {
        StatelessMmr { root, elements_count }
    }

    /// Compute the bagging of a given peaks. (Bagging == Hasing all the peaks from the last one to the first one)
    /// # Arguments
    /// * `peaks` - The current list of peaks.
    /// # Returns
    /// The bagged value of the peaks.
    fn bag_peaks(peaks: Span<T>) -> T {
        let peaks_len = peaks.len();
        assert(peaks_len > 0, 'ERR_INPUT_SHORT');

        if peaks_len == 1 {
            return *peaks.at(0);
        }

        let mut root = HHasher::hash_double(*peaks.at(peaks_len - 2), *peaks.at(peaks_len - 1));

        if peaks_len == 2 {
            return root;
        }

        let mut i = peaks_len - 3;
        let mut k = 0;
        loop {
            root = HHasher::hash_double(*peaks.at(i - k), root);
            if k + 3 == peaks_len {
                break ();
            };
            k += 1;
        };
        return root;
    }
    /// Compute the root of a given peaks.
    /// # Arguments
    /// * `peaks` - The current list of peaks.
    /// * `size` - The size of tree
    /// # Returns
    /// Root value of the tree.
    fn compute_root(peaks: Span<T>, size: usize) -> T {
        let bagged_peaks = StatelessMmrTrait::<T, H>::bag_peaks(peaks);
        let size_hashable: T = usize_to_T(size);
        let root = HHasher::hash_double(size_hashable, bagged_peaks);
        return root;
    }
    /// Compute the tree height of a given index
    /// # Arguments
    /// * `index` - Index of the element.
    /// # Returns
    /// The height of the tree.
    fn height(index: usize) -> usize {
        assert(index > 0, 'index must be at least 1');
        let bits = bit_length(index);
        let ones = left_shift(1, bits) - 1;
        if !(index == ones) {
            let shifted = left_shift(1, bits - 1);
            let shifted_index = (index - (shifted - 1));
            let rec_height = StatelessMmrTrait::<T, H>::height(shifted_index);
            return rec_height;
        }
        return bits - 1;
    }
    /// Append a new element to the MMR.
    /// # Arguments
    /// * `element` - The element to append.
    /// * `peaks` - The current list of peaks.
    /// * `last_elements_count` - The number of elements in the tree.
    /// * `last_root` - The root of the tree.
    /// # Returns
    /// The updated number of elements, the updated root and the updated list of peaks.
    fn append_element(
        self: StatelessMmr<T>, element: T, peaks: Array<T>
    ) -> (StatelessMmr<T>, Array<T>) {
        let (updated_elements_count, new_root, new_peaks): (usize, T, Array<T>) = do_append::<T,
        H>(element, peaks, self.elements_count, self.root);
        return (StatelessMmr { root: new_root, elements_count: updated_elements_count }, new_peaks);
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
        self: StatelessMmr<T>, elements: Array<T>, peaks: Array<T>, 
    ) -> (StatelessMmr<T>, Array<T>) {
        let mut elements_count = self.elements_count;
        let mut root = self.root;
        let mut updated_peaks = peaks;
        let mut i = 0;
        loop {
            if i == elements.len() {
                break ();
            };
            let (elements_count_temp, root_temp, updated_peaks_temp) = do_append::<T,
            H>(*elements.at(i), updated_peaks, elements_count, root);
            elements_count = elements_count_temp;
            root = root_temp;
            updated_peaks = updated_peaks_temp;
            i += 1;
        };

        return (StatelessMmr { root, elements_count }, updated_peaks);
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
    // /// Nothing if the proof is valid, an error otherwise.
    fn verify_proof(
        self: StatelessMmr<T>, index: usize, value: T, proof: Array<T>, peaks: Array<T>, 
    ) -> bool {
        assert(index <= self.elements_count, 'Index out of bound');
        let computed_root = StatelessMmrTrait::<T,
        H>::compute_root(peaks.span(), self.elements_count);
        assert(self.root == computed_root, 'Not matching root hashes');
        let hash = HHasher::hash_double(usize_to_T(index), value);
        let top_peak = get_proof_top_peak::<T, H>(0, hash, index, proof);
        let is_valid = array_contains::<T>(top_peak, peaks.span());

        return (is_valid);
    }
}

/// # Not on Implementation
fn get_proof_top_peak<
    T,
    H,
    impl TDrop: Drop<T>,
    impl TCopy: Copy<T>,
    impl TPartialEq: PartialEq<T>,
    impl HHasher: Hasher<T, T>,
    impl HDrop: Drop<H>
>(
    mut height: usize, mut hash: T, mut elements_count: usize, proof: Array<T>
) -> T {
    let mut i = 0;
    let mut current_sibling = hash;
    let mut next_height = 0;
    let mut is_higher = false;
    let mut hashed = hash;
    let mut parent_hash = hash;
    loop {
        if i == proof.len() {
            break ();
        };
        current_sibling = *proof.at(i);
        next_height = StatelessMmrTrait::<T, H>::height(elements_count + 1);
        if next_height >= height + 1 {
            is_higher = true;
        } else {
            is_higher = false;
        };
        if is_higher {
            hashed = HHasher::hash_double(current_sibling, hash);
            elements_count = elements_count + 1;
        } else {
            hashed = HHasher::hash_double(hash, current_sibling);
            elements_count = elements_count + left_shift(height, 2);
        };

        parent_hash = HHasher::hash_double(usize_to_T(elements_count), hashed);
        hash = parent_hash;
        height = height + 1;
        i += 1;
    };
    return hash;
}

fn do_append<
    T,
    H,
    impl TDrop: Drop<T>,
    impl TCopy: Copy<T>,
    impl TPartialEq: PartialEq<T>,
    impl HHasher: Hasher<T, T>,
    impl HDrop: Drop<H>,
>(
    elem: T, mut peaks: Array<T>, last_elements_count: usize, last_root: T
) -> (usize, T, Array<T>) {
    let elements_count = last_elements_count + 1;
    if last_elements_count == 0 {
        let root0 = HHasher::hash_double(usize_to_T(1), elem);
        let first_root = HHasher::hash_double(usize_to_T(1), root0);
        let mut new_peaks: Array<T> = Default::default();
        new_peaks.append(root0);
        return (elements_count, first_root, new_peaks);
    }
    let computed_root = StatelessMmrTrait::<T, H>::compute_root(peaks.span(), last_elements_count);
    assert(last_root == computed_root, 'Not matching root hashes');
    let hash = HHasher::hash_double(usize_to_T(elements_count), elem);
    peaks.append(hash);
    let (updated_peaks, updated_elements_count): (Array<T>, usize) = append_rec::<T,
    H>(0_usize, peaks, elements_count);
    let new_root = StatelessMmrTrait::<T,
    H>::compute_root(updated_peaks.span(), updated_elements_count);
    return (updated_elements_count, new_root, updated_peaks);
}
fn append_rec<
    T,
    H,
    impl TDrop: Drop<T>,
    impl TCopy: Copy<T>,
    impl TPartialEq: PartialEq<T>,
    impl HHasher: Hasher<T, T>,
    impl HDrop: Drop<H>
>(
    h: usize, peaks: Array<T>, last_elements_count: usize
) -> (Array<T>, usize) {
    let next_height = StatelessMmrTrait::<T, H>::height(last_elements_count + 1);
    let mut is_higher = false;
    if h + 1 <= next_height {
        is_higher = true;
    }
    let mut peaks_len = peaks.len();
    let elements_count = last_elements_count + 1;
    if is_higher {
        let right_hash = peaks.at(peaks_len - 1);
        let left_hash = peaks.at(peaks_len - 2);
        peaks_len = peaks_len - 2;

        let hash = HHasher::hash_double(*left_hash, *right_hash);
        let elements_count_type: T = usize_to_T(elements_count);
        let parent_hash = HHasher::hash_double(elements_count_type, hash);

        let mut merged_peaks: Array<T> = Default::default();
        let mut i = 0;
        loop {
            if i == peaks_len {
                break ();
            };
            merged_peaks.append(*peaks.at(i));
            i = i + 1;
        };
        merged_peaks.append(parent_hash);
        return append_rec::<T, H>(h + 1, merged_peaks, elements_count);
    }

    return (peaks, elements_count);
}


fn array_contains<T, impl TDrop: Drop<T>, impl TCopy: Copy<T>, impl TPartialEq: PartialEq<T>, >(
    elem: T, arr: Span<T>
) -> bool {
    let arr_len = arr.len();
    let mut i = 0;
    let mut result = false;
    loop {
        if i == arr_len {
            break ();
        }
        if *arr.at(i) == elem {
            result = true;
            break ();
        }
        i += 1;
    };
    return result;
}
#[test]
#[available_gas(10000000)]
fn test_array_contains() {
    let mut arr: Array<felt252> = Default::default();
    arr.append(0);
    arr.append(1);
    arr.append(2);

    assert(array_contains(0_felt252, arr.span()), 'array contains 0');
    assert(array_contains(1, arr.span()), 'array contains 1');
    assert(array_contains(2, arr.span()), 'array contains 2');
    assert(!array_contains(3, arr.span()), 'array does not contain 3');
}

#[test]
#[available_gas(200000)]
fn test_array_does_not_contain() {
    let arr: Array<felt252> = Default::default();
    assert(!array_contains(0, arr.span()), 'array does not contain 0');
}

