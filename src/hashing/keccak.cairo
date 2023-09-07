use cairo_lib::hashing::hasher::Hasher;
use cairo_lib::utils::math::pow;
use cairo_lib::utils::types::words64::{Words64, bytes_used};
use keccak::{keccak_u256s_le_inputs, cairo_keccak};

#[derive(Drop)]
struct Keccak {}

#[generate_trait]
impl KeccakHasher of KeccakTrait {
    fn keccak_cairo_word64(words: Words64) -> u256 {
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
}

impl KeccakHasherU256 of Hasher<u256, u256> {
    fn hash_single(a: u256) -> u256 {
        let mut arr = array![a];
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_double(a: u256, b: u256) -> u256 {
        let mut arr = array![a, b];
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_many(input: Span<u256>) -> u256 {
        keccak_u256s_le_inputs(input)
    }
}
