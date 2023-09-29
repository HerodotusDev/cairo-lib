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
// @param n The 256-bit unsigned integer
// @return The number of bits set to 1 in n
fn count_ones(n: u256) -> u256 {
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

// @notice Convert a leaf index to an Merkle Mountain Range tree leaf index
// @param n The leaf index
// @return The MMR index
fn leaf_index_to_mmr_index(n: u256) -> u256 {
    2 * n - 1 - count_ones(n - 1)
}

fn mmr_size_to_leaf_count(arg: u256) -> u256 {
    let mut mmr_size = arg;
    let bits = bit_length(mmr_size);
    let mut i = pow(2, bits);
    let mut leaf_count = 0;
    loop {
        if i == 0 {
            break leaf_count;
        }
        let x = 2 * i - 1;
        if x <= mmr_size {
            mmr_size -= x;
            leaf_count += i;
        }
        i /= 2;
    }
}

fn leaf_count_to_peaks_count(leaf_count: u256) -> u256 {
    count_ones(leaf_count)
}