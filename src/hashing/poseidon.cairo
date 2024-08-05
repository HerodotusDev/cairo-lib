use core::array::{ArrayTrait, ArrayImpl};
use cairo_lib::hashing::hasher::Hasher;
use cairo_lib::utils::types::words64::Words64;
use core::poseidon::{poseidon_hash_span, hades_permutation};

// @notice Hashes the given words using the Poseidon hash function.
// @param words The words to hash
// @return The hash of the words
pub fn hash_words64(words: Words64) -> felt252 {
    let mut arr = ArrayTrait::new();
    let mut i: usize = 0;
    loop {
        if i == words.len() {
            break poseidon_hash_span(arr.span());
        }

        arr.append((*words.at(i)).into());

        i += 1;
    }
}

// Permutation params: https://docs.starknet.io/documentation/architecture_and_concepts/Cryptography/hash-functions/#poseidon_hash
pub impl PoseidonHasher of Hasher<felt252, felt252> {
    // @inheritdoc Hasher
    fn hash_single(a: felt252) -> felt252 {
        let (single, _, _) = hades_permutation(a, 0, 1);
        single
    }

    // @inheritdoc Hasher
    fn hash_double(a: felt252, b: felt252) -> felt252 {
        let (double, _, _) = hades_permutation(a, b, 2);
        double
    }

    // @inheritdoc Hasher
    fn hash_many(input: Span<felt252>) -> felt252 {
        poseidon_hash_span(input)
    }
}
