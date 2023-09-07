use cairo_lib::utils::types::words64::{Words64, bytes_used};
use keccak::cairo_keccak;

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
    let mut last_word_bytes = bytes_used(last);
    if last_word_bytes == 8 {
        keccak_input.append(last);
        last = 0;
        last_word_bytes = 0;
    }

    cairo_keccak(ref keccak_input, last, last_word_bytes)
}
