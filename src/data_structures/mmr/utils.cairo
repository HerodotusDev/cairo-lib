use cairo_lib::utils::bitwise::{bit_length, left_shift};
use cairo_lib::utils::math::pow;

fn height(index: usize) -> usize {
    let bits = bit_length(index);
    let ones = pow(2, bits) - 1;

    if index != ones {
        let shifted = left_shift(1, bits - 1);
        return height(index - (shifted - 1));
    }

    bits - 1
}
