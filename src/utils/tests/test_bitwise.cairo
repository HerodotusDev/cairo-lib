use cairo_lib::utils::bitwise::{left_shift, right_shift, bit_length, reverse_endianness_u256};

#[test]
#[available_gas(999999)]
fn test_left_shift() {
    assert(left_shift(1_u32, 0_u32) == 1, '1 << 0');
    assert(left_shift(1_u32, 1_u32) == 2, '1 << 1');
    assert(left_shift(1_u32, 2_u32) == 4, '1 << 2');
    assert(left_shift(1_u32, 8_u32) == 256, '1 << 8');
    assert(left_shift(2_u32, 8_u32) == 512, '2 << 8');
    assert(left_shift(255_u32, 8_u32) == 65280, '255 << 8');
}

#[test]
#[available_gas(999999)]
fn test_right_shift() {
    assert(right_shift(1_u32, 0_u32) == 1, '1 >> 0');
    assert(right_shift(2_u32, 1_u32) == 1, '2 >> 1');
    assert(right_shift(4_u32, 2_u32) == 1, '4 >> 2');
    assert(right_shift(256_u32, 8_u32) == 1, '256 >> 8');
    assert(right_shift(512_u32, 8_u32) == 2, '512 >> 8');
    assert(right_shift(65280_u32, 8_u32) == 255, '65280 >> 8');
    assert(right_shift(128392_u32, 33_u32) == 0, '128392 >> 33');
}

#[test]
#[available_gas(999999)]
fn test_bit_length() {
    assert(bit_length(0_u32) == 0, 'bit length of 0 is 0');
    assert(bit_length(1_u32) == 1, 'bit length of 1 is 1');
    assert(bit_length(2_u128) == 2, 'bit length of 2 is 2');
    assert(bit_length(5_u8) == 3, 'bit length of 5 is 3');
    assert(bit_length(7_u128) == 3, 'bit length of 7 is 3');
    assert(bit_length(8_u32) == 4, 'bit length of 8 is 4');
}

#[test]
#[available_gas(999999999)]
fn test_bit_length_most_significant_bit_one() {
    assert(bit_length(4294967295_u32) == 32, 'bit length of 2^32-1 is 32');
}

#[test]
#[available_gas(999999)]
fn test_reverse_endianness_u256() {
    assert(reverse_endianness_u256(0) == 0, 'reverse endianness of 0');
    assert(
        reverse_endianness_u256(
            1
        ) == 0x0100000000000000000000000000000000000000000000000000000000000000,
        'reverse endianness of 1'
    );
    assert(
        reverse_endianness_u256(
            0x1307645868aee0028be496b378bfeee2bac59d1239549a8ef4bff9009af5ef
        ) == 0xEFF59A00F9BFF48E9A5439129DC5BAE2EEBF78B396E48B02E0AE685864071300,
        'reverse endianness of 31 bytes'
    );
}

