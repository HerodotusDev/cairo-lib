use cairo_lib::encoding::rlp_word64::{RLPItemWord64, rlp_decode_word64};
use array::ArrayTrait;
use result::ResultTrait;
use debug::PrintTrait;

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_word64_string() {
    let mut i = 1;
    loop {
        if i == 0x80 {
            break ();
        }
        let mut arr = ArrayTrait::new();
        //let rev = reverse_endianness(i);
        arr.append(i);

        let (res, len) = rlp_decode_word64(arr.span()).unwrap();
        assert(len == 1, 'Wrong len');
        assert(res == RLPItemWord64::Bytes(arr.span()), 'Wrong value');

        i += 1;
    };
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_word64_short_string() {
    let mut arr = array![
        0x39c034f66c805a9b,
        0x1ea949fd892d8f8d,
        0xbb9484cd74a43df3,
        0xa8da3bf7
    ];

    let (res, len) = rlp_decode_word64(arr.span()).unwrap();
    assert(len == 1 + (0x9b - 0x80), 'Wrong len');

    let mut expected_res = array![
        0x8d39c034f66c805a,
        0xf31ea949fd892d8f,
        0xf7bb9484cd74a43d,
        0xa8da3b
    ];
    let expected_item = RLPItemWord64::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_word64_long_string_len_1() {
    let mut arr = array![
        0xd459f97ea1f73cb8,
        0x103a7b34dc8d3888,
        0x6a98370c1d4385dd,
        0xa4b18da3ba18bd63,
        0x6e16ecc3de246f81,
        0x0479f7c4c4acb2b3,
        0xda53d0c6673c76ba,
        0xd97d198610ea
    ];

    let (res, len) = rlp_decode_word64(arr.span()).unwrap();
    assert(len == 1 + (0xb8 - 0xb7) + 0x3c, 'Wrong len');

    let mut expected_res = array![
        0x3888d459f97ea1f7,
        0x85dd103a7b34dc8d,
        0xbd636a98370c1d43,
        0x6f81a4b18da3ba18,
        0xb2b36e16ecc3de24,
        0x76ba0479f7c4c4ac,
        0x10eada53d0c6673c,
        0xd97d1986
    ];
    let expected_item = RLPItemWord64::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}
