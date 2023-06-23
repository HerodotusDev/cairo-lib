use cairo_lib::encoding::rlp::{rlp_decode, RLPType, RLPTypeTrait, RLPItem};
use cairo_lib::utils::types::Bytes;
use array::{ArrayTrait, SpanTrait};
use core::result::ResultTrait;

#[test]
#[available_gas(9999999)]
fn test_rlp_types() {
    let mut i = 0;
    loop {
        if i <= 0x7f {
            assert(RLPTypeTrait::from_byte(i).unwrap() == RLPType::String(()), 'Parse type String');
        } else if i <= 0xb7 {
            assert(RLPTypeTrait::from_byte(i).unwrap() == RLPType::StringShort(()), 'Parse type StringShort');
        } else if i <= 0xbf {
            assert(RLPTypeTrait::from_byte(i).unwrap() == RLPType::StringLong(()), 'Parse type StringLong');
        } else if i <= 0xf7 {
            assert(RLPTypeTrait::from_byte(i).unwrap() == RLPType::ListShort(()), 'Parse type ListShort');
        } else if i <= 0xff {
            assert(RLPTypeTrait::from_byte(i).unwrap() == RLPType::ListLong(()), 'Parse type ListLong');
        }

        if i == 0xff {
            break ();
        }
        i += 1;
    };
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_string() {
    let mut i = 0;
    loop {
        if i == 0x80 {
            break ();
        }
        let mut arr = ArrayTrait::new();
        arr.append(i);

        let res = rlp_decode(arr.span()).unwrap();
        assert(res.len() == 1, 'Wrong len');
        assert(res.at(0) == @RLPItem::Bytes(arr.span()), 'Wrong value');

        i += 1;
    };
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_short_string() {
    let mut arr = ArrayTrait::new();
    // Apend this number nibble by nibble:
    // 0x9b5a806cf634c0398d8f2d89fd49a91ef33da474cd8494bba8da3bf7
    arr.append(0x9b);
    arr.append(0x5a);
    arr.append(0x80);
    arr.append(0x6c);
    arr.append(0xf6);
    arr.append(0x34);
    arr.append(0xc0);
    arr.append(0x39);
    arr.append(0x8d);
    arr.append(0x8f);
    arr.append(0x2d);
    arr.append(0x89);
    arr.append(0xfd);
    arr.append(0x49);
    arr.append(0xa9);
    arr.append(0x1e);
    arr.append(0xf3);
    arr.append(0x3d);
    arr.append(0xa4);
    arr.append(0x74);
    arr.append(0xcd);
    arr.append(0x84);
    arr.append(0x94);
    arr.append(0xbb);
    arr.append(0xa8);
    arr.append(0xda);
    arr.append(0x3b);
    arr.append(0xf7);

    let res = rlp_decode(arr.span()).unwrap();
    assert(res.len() == 1, 'Wrong len');

    arr.pop_front();
    let expected_item = RLPItem::Bytes(arr.span());

    assert(res.at(0) == @expected_item, 'Wrong value');
}
