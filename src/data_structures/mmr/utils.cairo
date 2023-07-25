use cairo_lib::utils::bitwise::{bit_length, left_shift};
use cairo_lib::utils::math::pow;
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};

fn get_height(index: usize) -> usize {
    let bits = bit_length(index);
    let ones = pow(2, bits) - 1;

    if index != ones {
        let shifted = left_shift(1, bits - 1);
        return get_height(index - (shifted - 1));
    }

    bits - 1
}

fn compute_root(last_pos: felt252, peaks: Peaks) -> felt252 {
    let bag = peaks.bag();
    PoseidonHasher::hash_double(last_pos, bag)
}
