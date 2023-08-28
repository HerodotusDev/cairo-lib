use cairo_lib::utils::types::words64::{Words64, Words64Trait};
use array::{ArrayTrait, SpanTrait};

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_multiple_words_not_full() {
    let val: Words64 = array![0xabcdef1234567890, 0x7584934785943295, 0x48542576].span();

    let res = val.slice_le(5, 17);
    assert(res.len() == 3, 'Wrong len');
    assert(*res.at(0) == 0x3295abcdef123456, 'Wrong value at 0');
    assert(*res.at(1) == 0x2576758493478594, 'Wrong value at 1');
    assert(*res.at(2) == 0x54, 'Wrong value at 2');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_multiple_words_full() {
    let val: Words64 = array![0xabcdef1234567890, 0x7584934785943295, 0x48542576].span();

    let gas = testing::get_available_gas();
    let res = val.slice_le(4, 16);
    assert(res.len() == 2, 'Wrong len');
    assert(*res.at(0) == 0x943295abcdef1234, 'Wrong value at 0');
    assert(*res.at(1) == 0x5425767584934785, 'Wrong value at 1');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_single_word_not_full() {
    let val: Words64 = array![0xabcdef1234567890, 0x7584934785943295, 0x48542576].span();

    let res = val.slice_le(1, 5);
    assert(res.len() == 1, 'Wrong len');
    assert(*res.at(0) == 0x943295abcd, 'Wrong value at 0');
}

#[test]
#[available_gas(99999999)]
fn test_slice_words64_le_single_word_full() {
    let val: Words64 = array![0xabcdef1234567890, 0x7584934785943295, 0x48542576].span();

    let res = val.slice_le(15, 8);
    assert(res.len() == 1, 'Wrong len');
    assert(*res.at(0) == 0x7584934785943295, 'Wrong value at 0');
}
