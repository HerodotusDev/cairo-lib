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

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_word64_long_string_len_2() {
    let mut arr = array![
        0x59f97ea1f70201b9,
        0x3a7b34dc8d3888d4,
        0x98370c1d4385dd10,
        0xb18da3ba18bd636a,
        0x16ecc3de246f81a4,
        0x79f7c4c4acb2b36e,
        0x53d0c6673c76ba04,
        0x33d97d198610eada,
        0x6743897634694758,
        0x8967953487764593,
        0x3463437986433634,
        0x6459836758496378,
        0x4369695874933756,
        0x8963459867483967,
        0x4056046337946745,
        0x0365406808436839,
        0x8736956448938046,
        0x9534897673568439,
        0x3498609340657386,
        0x5908368056048356,
        0x5940680683064568,
        0x4830680384654068,
        0x9568574983460365,
        0x8769748376346879,
        0x4798637584635943,
        0x4365879473863456,
        0x5786347996346798,
        0x8956873469574893,
        0x7953564973685734,
        0x4738799634679543,
        0x4553638967946353,
        0x6868876897887968,
        0x6087997668
    ];

    let (res, len) = rlp_decode_word64(arr.span()).unwrap();
    assert(len == 1 + (0xb9 - 0xb7) + 0x0102, 'Wrong len');

    let mut expected_res = array![
        0x3888d459f97ea1f7,
        0x85dd103a7b34dc8d,
        0xbd636a98370c1d43,
        0x6f81a4b18da3ba18,
        0xb2b36e16ecc3de24,
        0x76ba0479f7c4c4ac,
        0x10eada53d0c6673c,
        0x69475833d97d1986,
        0x7645936743897634,
        0x4336348967953487,
        0x4963783463437986,
        0x9337566459836758,
        0x4839674369695874,
        0x9467458963459867,
        0x4368394056046337,
        0x9380460365406808,
        0x5684398736956448,
        0x6573869534897673,
        0x0483563498609340,
        0x0645685908368056,
        0x6540685940680683,
        0x4603654830680384,
        0x3468799568574983,
        0x6359438769748376,
        0x8634564798637584,
        0x3467984365879473,
        0x5748935786347996,
        0x6857348956873469,
        0x6795437953564973,
        0x9463534738799634,
        0x8879684553638967,
        0x9976686868876897,
        0x6087
    ];
    let expected_item = RLPItemWord64::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}
