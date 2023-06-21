use cairo_lib::hashing::hasher::Hasher;
use array::{ArrayTrait, SpanTrait};
use keccak::keccak_u256s_le_inputs;
use traits::Into;

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
