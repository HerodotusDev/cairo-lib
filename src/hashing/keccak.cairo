use cairo_lib::utils::types::words64::{Words64, bytes_used_u64};
use keccak::cairo_keccak;

// @notice Wrapper arround cairo_keccak that format the input for compatibility with EVM
// @param words The input data, as a list of 64-bit little-endian words
// @return The keccak hash of the input, matching the output of the EVM's keccak256 opcode
fn keccak_cairo_words64(words: Words64) -> u256 {
    let n = words.len();

    let mut keccak_input = ArrayTrait::new();
    let mut i: usize = 0;
    if n > 1 {
        loop {
            if i >= n - 1 {
                break ();
            }
            keccak_input.append(*words.at(i));
            i += 1;
        };
    }

    let mut last = *words.at(n - 1);
    let mut last_word_bytes = bytes_used_u64(last);
    if last_word_bytes == 8 {
        keccak_input.append(last);
        last = 0;
        last_word_bytes = 0;
    }

    cairo_keccak(ref keccak_input, last, last_word_bytes)
}
