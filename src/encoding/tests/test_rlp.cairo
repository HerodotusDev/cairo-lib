use cairo_lib::encoding::rlp::{rlp_decode, RLPType, RLPTypeTrait, RLPItem};
use cairo_lib::utils::types::Bytes;
use array::ArrayTrait;
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
