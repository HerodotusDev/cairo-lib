use cairo_lib::hashing::keccak::KeccakTrait;
use array::ArrayTrait;

#[test]
#[available_gas(99999999)]
fn test_keccak_cairo_full_byte() {
    let mut input =  ArrayTrait::new();
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);
    input.append(0xff);

    let res = KeccakTrait::keccak_cairo(input.span());
    assert(res == 0xAF7D4E460ACF8E540E682A9EE91EA1C08C1615C3889D75EB0A70660A4BFB0BAD, 'Keccak output not matching');
}

#[test]
#[available_gas(99999999)]
fn test_keccak_cairo_remainder() {
    let mut input =  ArrayTrait::new();
    // append: ab768cf789aefd234abcd245
    input.append(0xab);
    input.append(0x76);
    input.append(0x8c);
    input.append(0xf7);
    input.append(0x89);
    input.append(0xae);
    input.append(0xfd);
    input.append(0x23);
    input.append(0x4a);
    input.append(0xbc);
    input.append(0xd2);
    input.append(0x45);

    let res = KeccakTrait::keccak_cairo(input.span());
    assert(res == 0x82CBD5B00CD06A188C831D69CB9629C92A2D5E7A78CEA913C5F9AFF62E66BBB9, 'Keccak output not matching');
}
