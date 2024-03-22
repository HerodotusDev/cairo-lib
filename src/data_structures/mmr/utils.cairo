use cairo_lib::utils::bitwise::{bit_length, left_shift};
use cairo_lib::utils::math::pow;
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};

// @notice Computes the height of a node in the MMR
// @param index The index of the node
// @return The height of the node
fn get_height(index: usize) -> usize {
    let bits = bit_length(index);
    let ones = pow(2, bits) - 1;

    if index != ones {
        let shifted = left_shift(1, bits - 1);
        return get_height(index - (shifted - 1));
    }

    bits - 1
}

// @notice Computes the root of the MMR
// @param last_pos The position of the last node in the MMR
// @param peaks The peaks of the MMR
// @return The root of the MMR
fn compute_root(last_pos: felt252, peaks: Peaks) -> felt252 {
    let bag = peaks.bag();
    PoseidonHasher::hash_double(last_pos, bag)
}

// @notice Count the number of bits set to 1 in a 256-bit unsigned integer
// @param arg The 256-bit unsigned integer
// @return The number of bits set to 1 in n
fn count_ones(n: u32) -> u32 {
    let mut n = n;
    let mut count = 0;
    loop {
        if n == 0 {
            break count;
        }
        n = n & (n - 1);
        count += 1;
    }
}

// @notice Convert a leaf index to an Merkle Mountain Range tree index
// @param n The leaf index
// @return The MMR index
// Explanation of why this formula is correct
// https://mmr.herodotus.dev/mmr-size-vs-leaf-count#leaf-count-to-mmr-size-algorithm
fn leaf_index_to_mmr_index(n: u32) -> u32 {
    2 * n - 1 - count_ones(n - 1)
}

// @notice Convert a Merkle Mountain Range tree size to number of leaves
// @param n MMR size
// @result Number of leaves
// Explanation of why this algorithm is correct
// https://mmr.herodotus.dev/mmr-size-vs-leaf-count#mmr-size-to-leaf-count-algorithm
fn mmr_size_to_leaf_count(n: u32) -> u32 {
    let mut mmr_size = n;
    let bits = bit_length(mmr_size + 1);
    let mut mountain_leaf_count = pow(2, bits - 1);
    let mut leaf_count = 0;
    loop {
        if mountain_leaf_count == 0 {
            break leaf_count;
        }
        let mountain_size = 2 * mountain_leaf_count - 1;
        if mountain_size <= mmr_size {
            mmr_size -= mountain_size;
            leaf_count += mountain_leaf_count;
        }
        mountain_leaf_count /= 2;
    }
}


// @notice Convert a number of leaves to number of peaks
// @param leaf_count Number of leaves
// @return Number of peaks
fn leaf_count_to_peaks_count(leaf_count: u32) -> u32 {
    count_ones(leaf_count)
}

// @notice Get the number of trailing ones in the binary representation of a number
// @param n The number
// @return Number of trailing ones
fn trailing_ones(n: u32) -> u32 {
    let mut n = n;
    let mut count = 0;
    loop {
        if n % 2 == 0 {
            break count;
        }
        n /= 2;
        count += 1;
    }
}

// @notice Get peak size and index of the peak the element is in
// @param elements_count The size of the MMR (number of elements in the MMR)
// @param element_index The index of the element in the MMR
// @return (peak index, peak height)
fn get_peak_info(elements_count: u32, element_index: u32) -> (u32, u32) {
    let mut elements_count = elements_count;
    let mut element_index = element_index;

    let mut mountain_height = bit_length(elements_count);
    let mut mountain_elements_count = pow(2, mountain_height) - 1;
    let mut mountain_index = 0;
    loop {
        if mountain_elements_count <= elements_count {
            if element_index <= mountain_elements_count {
                break (mountain_index, mountain_height - 1);
            }
            elements_count -= mountain_elements_count;
            element_index -= mountain_elements_count;
            mountain_index += 1;
        }
        mountain_height -= 1;
        mountain_elements_count /= 2;
    }
}
