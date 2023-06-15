use cairo_lib::hashing::hasher::Hasher;
use poseidon::poseidon_hash_span;
use array::ArrayTrait;

struct Poseidon {}

impl PoseidonHasher of Hasher<felt252, felt252> {
    fn hash_single(a: felt252) -> felt252 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        poseidon_hash_span(arr.span())
    }

    fn hash_double(a: felt252, b: felt252) -> felt252 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        arr.append(b);
        poseidon_hash_span(arr.span())
    }

    fn hash_many(input: Span<felt252>) -> felt252 {
        poseidon_hash_span(input)
    }
}
