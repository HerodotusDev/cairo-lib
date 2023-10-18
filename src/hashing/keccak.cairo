use cairo_lib::utils::types::words64::{Words64, bytes_used_u64};
use keccak::cairo_keccak;

const EMPTY_KECCAK: u256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

// @notice Wrapper arround cairo_keccak that format the input for compatibility with EVM
// @param words The input data, as a list of 64-bit little-endian words
// @param last_word_bytes Number of bytes in the last word
// @return The keccak hash of the input, matching the output of the EVM's keccak256 opcode
fn keccak_cairo_words64(words: Words64, last_word_bytes: usize) -> u256 {
    if words.is_empty() {
        return EMPTY_KECCAK;
    }
    
    let n = words.len();
    let mut keccak_input = ArrayTrait::new();
    let mut i: usize = 0;
    loop {
        if i >= n - 1 {
            break ();
        }
        keccak_input.append(*words.at(i));
        i += 1;
    };

    let mut last = *words.at(n - 1);
    if last_word_bytes == 8 {
        keccak_input.append(last);
        cairo_keccak(ref keccak_input, 0, 0)
    } else {
        cairo_keccak(ref keccak_input, last, last_word_bytes)
    }

}
