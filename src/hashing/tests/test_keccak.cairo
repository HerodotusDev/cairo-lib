use cairo_lib::hashing::keccak::KeccakTrait;

#[test]
#[available_gas(99999999)]
fn test_keccak_cairo_word64_full_byte() {
    let input = array![0xffffffffffffffff];

    let res = KeccakTrait::keccak_cairo_word64(input.span());
    assert(
        res == 0xAF7D4E460ACF8E540E682A9EE91EA1C08C1615C3889D75EB0A70660A4BFB0BAD,
        'Keccak output not matching'
    );
}

#[test]
#[available_gas(99999999999)]
fn test_keccak_cairo_word64_remainder() {
    let mut input = array![0x23FDAE89F78C76AB, 0x45D2BC4A];

    let res = KeccakTrait::keccak_cairo_word64(input.span());
    assert(
        res == 0x82CBD5B00CD06A188C831D69CB9629C92A2D5E7A78CEA913C5F9AFF62E66BBB9,
        'Keccak output not matching'
    );
}
