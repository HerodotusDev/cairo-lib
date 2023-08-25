use cairo_lib::utils::bitwise::{left_shift, right_shift, bit_length, slice_words64_le};
use array::{ArrayTrait, SpanTrait};
use debug::PrintTrait;
use option::OptionTrait;

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
#[available_gas(99999999)]
fn test_slice_words64_le_multiple_words_not_full() {
    let val = array![
        0xabcdef1234567890, 
        0x7584934785943295, 
        0x48542576
    ].span();

    let res = slice_words64_le(val, 5, 17);
    assert(res.len() == 3, 'Wrong len');
    assert(*res.at(0) == 0x3295abcdef123456, 'Wrong value at 0');
    assert(*res.at(1) == 0x2576758493478594, 'Wrong value at 1');
    assert(*res.at(2) == 0x54, 'Wrong value at 2');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_multiple_words_full() {
    let val = array![
        0xabcdef1234567890, 
        0x7584934785943295, 
        0x48542576
    ].span();


let gas = testing::get_available_gas();
    let res = slice_words64_le(val, 4, 16);
    assert(res.len() == 2, 'Wrong len');
    assert(*res.at(0) == 0x943295abcdef1234, 'Wrong value at 0');
    assert(*res.at(1) == 0x5425767584934785, 'Wrong value at 1');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_single_word_not_full() {
    let val = array![
        0xabcdef1234567890, 
        0x7584934785943295, 
        0x48542576
    ].span();


    let res = slice_words64_le(val, 1, 5);
    assert(res.len() == 1, 'Wrong len');
    assert(*res.at(0) == 0x943295abcd, 'Wrong value at 0');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_single_word_full() {
    let val = array![
        0xabcdef1234567890, 
        0x7584934785943295, 
        0x48542576
    ].span();


    let res = slice_words64_le(val, 15, 8);
    assert(res.len() == 1, 'Wrong len');
    assert(*res.at(0) == 0x7584934785943295, 'Wrong value at 0');
}
