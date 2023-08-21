use cairo_lib::hashing::keccak::KeccakTrait;
use array::ArrayTrait;

#[test]
#[available_gas(99999999)]
fn test_keccak_cairo_full_byte() {
    let mut input =  array![0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff];

    let res = KeccakTrait::keccak_cairo(input.span());
    assert(res == 0xAF7D4E460ACF8E540E682A9EE91EA1C08C1615C3889D75EB0A70660A4BFB0BAD, 'Keccak output not matching');
}

#[test]
#[available_gas(99999999)]
fn test_keccak_cairo_remainder() {
    let mut input =  array![0xab, 0x76, 0x8c, 0xf7, 0x89, 0xae, 0xfd, 0x23, 0x4a, 0xbc, 0xd2, 0x45];

    let res = KeccakTrait::keccak_cairo(input.span());
    assert(res == 0x82CBD5B00CD06A188C831D69CB9629C92A2D5E7A78CEA913C5F9AFF62E66BBB9, 'Keccak output not matching');
}
