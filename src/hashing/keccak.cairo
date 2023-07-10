use cairo_lib::hashing::hasher::Hasher;
use cairo_lib::utils::math::pow;
use cairo_lib::utils::types::bytes::Bytes;
use array::{ArrayTrait, SpanTrait};
use keccak::keccak_u256s_le_inputs;
use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::SyscallResultTrait;

#[derive(Drop)]
struct Keccak {}

impl KeccakHasherU256 of Hasher<u256, u256> {
    fn hash_single(a: u256) -> u256 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_double(a: u256, b: u256) -> u256 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        arr.append(b);
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_many(input: Span<u256>) -> u256 {
        keccak_u256s_le_inputs(input)
    }
}

impl KeccakHasherSpanU8 of Hasher<Span<u8>, u256> {
    fn hash_single(a: Span<u8>) -> u256 {
        let mut arr = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i >= a.len() {
                break arr.span();
            }
            let current = *a.at(i);
            arr.append(current.into());
            i += 1;
        };
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_double(a: Span<u8>, b: Span<u8>) -> u256 {
        let mut arr = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i >= a.len() {
                break arr.span();
            }
            let current = *a.at(i);
            arr.append(current.into());
            i += 1;
        };

        i = 0;
        loop {
            if i >= b.len() {
                break arr.span();
            }
            let current = *b.at(i);
            arr.append(current.into());
            i += 1;
        };
        keccak_u256s_le_inputs(arr.span())
    }

    fn hash_many(input: Span<Span<u8>>) -> u256 {
        let mut arr = ArrayTrait::new();
        let mut i: usize = 0;
        let mut j: usize = 0;
        loop {
            if i >= input.len() {
                break arr.span();
            }

            let current = *input.at(i);
            loop {
                if j >= current.len() {
                    break;
                }
                let current = *current.at(j);
                arr.append(current.into());
                j += 1;
            };
            i+=1;
        };

        keccak_u256s_le_inputs(arr.span())
    }
}

#[generate_trait]
impl KeccakHasher of KeccakTrait {
    // Expectes big endian input, returns little endian
    fn keccak_cairo(bytes: Bytes) -> u256 {
        let n = bytes.len();
        let q = n / 8;
        let r = n % 8;

        let mut keccak_input = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i >= q {
                break ();
            }

            let val =
                (*bytes.at(8*i)).into() + 
                (*bytes.at(8*i+1)).into() * 256 + 
                (*bytes.at(8*i+2)).into() * 65536 + 
                (*bytes.at(8*i+3)).into() * 16777216 +
                (*bytes.at(8*i+4)).into() * 4294967296 +
                (*bytes.at(8*i+5)).into() * 1099511627776 + 
                (*bytes.at(8*i+6)).into() * 281474976710656 + 
                (*bytes.at(8*i+7)).into() * 72057594037927936;

            keccak_input.append(val);

            i += 1;
        };

        let mut last_word: u64 = 0;
        let mut k: usize = 0;
        loop {
            if k >= r {
                break ();
            }
           
            let current: u64 = (*bytes.at(8*q+k)).into();
            last_word += current * pow(256, k.into());

            k += 1;
        };

        cairo_keccak(ref keccak_input, last_word, r)
    }
}

const KECCAK_FULL_RATE_IN_BYTES: usize = 136;
const KECCAK_FULL_RATE_IN_U64S: usize = 17;
const BYTES_IN_U64_WORD: usize = 8;

// Computes the keccak of `input` + `last_input_num_bytes` LSB bytes of `last_input_word`.
// To use this function, split the input into words of 64 bits (little endian).
// For example, to compute keccak('Hello world!'), use:
//   inputs = [8031924123371070792, 560229490]
// where:
//   8031924123371070792 == int.from_bytes(b'Hello wo', 'little')
//   560229490 == int.from_bytes(b'rld!', 'little')
//
// Returns the hash as a little endian u256.
fn cairo_keccak(ref input: Array<u64>, last_input_word: u64, last_input_num_bytes: usize) -> u256 {
    add_padding(ref input, last_input_word, last_input_num_bytes);
    starknet::syscalls::keccak_syscall(input.span()).unwrap_syscall()
}

// The padding in keccak256 is "1 0* 1".
// `last_input_num_bytes` (0-7) is the number of bytes in the last u64 input - `last_input_word`.
fn add_padding(ref input: Array<u64>, last_input_word: u64, last_input_num_bytes: usize) {
    let words_divisor = KECCAK_FULL_RATE_IN_U64S.try_into().unwrap();
    // `last_block_num_full_words` is in range [0, KECCAK_FULL_RATE_IN_U64S - 1]
    let (_, last_block_num_full_words) = integer::u32_safe_divmod(input.len(), words_divisor);
    // `last_block_num_bytes` is in range [0, KECCAK_FULL_RATE_IN_BYTES - 1]
    let last_block_num_bytes = last_block_num_full_words * BYTES_IN_U64_WORD + last_input_num_bytes;

    // The first word to append would be of the form
    //     0x1<`last_input_num_bytes` LSB bytes of `last_input_word`>.
    // For example, for `last_input_num_bytes == 4`:
    //     0x1000000 + (last_input_word & 0xffffff)
    let first_word_to_append = if last_input_num_bytes == 0 {
        // This case is handled separately to avoid unnecessary computations.
        1
    } else {
        let first_padding_byte_part = if last_input_num_bytes == 1 {
            0x100
        } else if last_input_num_bytes == 2 {
            0x10000
        } else if last_input_num_bytes == 3 {
            0x1000000
        } else if last_input_num_bytes == 4 {
            0x100000000
        } else if last_input_num_bytes == 5 {
            0x10000000000
        } else if last_input_num_bytes == 6 {
            0x1000000000000
        } else if last_input_num_bytes == 7 {
            0x100000000000000
        } else {
            panic_with_felt252('Keccak last input word >7b')
        };
        let (_, r) = integer::u64_safe_divmod(
            last_input_word, first_padding_byte_part.try_into().unwrap()
        );
        first_padding_byte_part + r
    };

    if last_block_num_full_words == KECCAK_FULL_RATE_IN_U64S - 1 {
        input.append(0x8000000000000000 + first_word_to_append);
        return;
    }

    // last_block_num_full_words < KECCAK_FULL_RATE_IN_U64S - 1
    input.append(first_word_to_append);
    finalize_padding(ref input, KECCAK_FULL_RATE_IN_U64S - 1 - last_block_num_full_words);
}

// Finalize the padding by appending "0* 1".
fn finalize_padding(ref input: Array<u64>, num_padding_words: u32) {
    if (num_padding_words == 1) {
        input.append(0x8000000000000000);
        return;
    }

    input.append(0);
    finalize_padding(ref input, num_padding_words - 1);
}
