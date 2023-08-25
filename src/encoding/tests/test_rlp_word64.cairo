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
    let expected_item = RLPItemWord64::Bytes(arr.span());
    assert(res == expected_item, 'Wrong value');
}
