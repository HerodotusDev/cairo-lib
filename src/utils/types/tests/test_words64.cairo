use cairo_lib::utils::types::words64::{
    Words64, Words64Trait, reverse_endianness_u64, bytes_used_u64
};

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

#[test]
#[available_gas(99999999)]
fn test_as_u256_be_full() {
    let words = array![
        0x2e8b632605e21673, 0x480829ebcee54bc4, 0xb6f239256ff310f9, 0x09898da43a5d35f4,
    ]
        .span();

    let expected = 0x7316e20526638b2ec44be5ceeb290848f910f36f2539f2b6f4355d3aa48d8909;
    assert(words.as_u256_be(32).unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_as_u256_be_not_full() {
    let words = array![0x2e8b632605e21673, 0x480829ebcee54bc4, 0xb6f2392a].span();

    let expected = 0x7316e20526638b2ec44be5ceeb2908482a39f2b6;
    assert(words.as_u256_be(20).unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_as_u256_be_not_full_start() {
    let words = array![0x008b632605e20000, 0x480829ebcee54bc4, 0xb6f2392a].span();

    let expected = 0xe20526638b00c44be5ceeb2908482a39f2b6;
    assert(words.as_u256_be(20).unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_as_u256_be_not_full_end() {
    let words = array![0x2e8b632605e20000, 0x480829ebcee54bc4, 0xb6f2392a].span();

    let expected = 0x0000e20526638b2ec44be5ceeb2908482a39f2b600;
    assert(words.as_u256_be(21).unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_as_u256_le_full() {
    let words = array![
        0x2e8b632605e21673, 0x480829ebcee54bc4, 0xb6f239256ff310f9, 0x09898da43a5d35f4,
    ]
        .span();

    let expected = 0x09898DA43A5D35F4B6F239256FF310F9480829EBCEE54BC42E8B632605E21673;
    assert(words.as_u256_le().unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_as_u256_le_not_full() {
    let words = array![0x2e8b632605e21673, 0x480829ebcee54bc4, 0xb6f239256ff310f9].span();

    let expected = 0xB6F239256FF310F9480829EBCEE54BC42E8B632605E21673;
    assert(words.as_u256_le().unwrap() == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_reverse_endianness_u64() {
    let val = 0x1234567890abcdef;
    let expected = 0xefcdab9078563412;
    assert(reverse_endianness_u64(val, Option::None(())) == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_reverse_endianness_not_full() {
    let val = 0xabcdef;
    let expected = 0xefcdab;
    assert(reverse_endianness_u64(val, Option::Some(3)) == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_reverse_endianness_not_full_padding() {
    let val = 0xabcdef;
    let expected = 0xefcdab00;
    assert(reverse_endianness_u64(val, Option::Some(4)) == expected, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_bytes_used() {
    let mut num = 0x1234567890abcdef;
    let pow2 = 0x100;

    let mut i = 8;
    loop {
        assert(bytes_used_u64(num) == i, 'Wrong value');
        num = num / pow2;

        if i == 0 {
            break ();
        }

        i -= 1;
    }
}
