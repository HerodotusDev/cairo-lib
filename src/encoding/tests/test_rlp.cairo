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

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_long_string_len_of_len_1() {
    let mut arr = ArrayTrait::new();
    arr.append(0xb8);
    arr.append(0x3c);
    arr.append(0xf7);
    arr.append(0xa1);
    arr.append(0x7e);
    arr.append(0xf9);
    arr.append(0x59);
    arr.append(0xd4);
    arr.append(0x88);
    arr.append(0x38);
    arr.append(0x8d);
    arr.append(0xdc);
    arr.append(0x34);
    arr.append(0x7b);
    arr.append(0x3a);
    arr.append(0x10);
    arr.append(0xdd);
    arr.append(0x85);
    arr.append(0x43);
    arr.append(0x1d);
    arr.append(0x0c);
    arr.append(0x37);
    arr.append(0x98);
    arr.append(0x6a);
    arr.append(0x63);
    arr.append(0xbd);
    arr.append(0x18);
    arr.append(0xba);
    arr.append(0xa3);
    arr.append(0x8d);
    arr.append(0xb1);
    arr.append(0xa4);
    arr.append(0x81);
    arr.append(0x6f);
    arr.append(0x24);
    arr.append(0xde);
    arr.append(0xc3);
    arr.append(0xec);
    arr.append(0x16);
    arr.append(0x6e);
    arr.append(0xb3);
    arr.append(0xb2);
    arr.append(0xac);
    arr.append(0xc4);
    arr.append(0xc4);
    arr.append(0xf7);
    arr.append(0x79);
    arr.append(0x04);
    arr.append(0xba);
    arr.append(0x76);
    arr.append(0x3c);
    arr.append(0x67);
    arr.append(0xc6);
    arr.append(0xd0);
    arr.append(0x53);
    arr.append(0xda);
    arr.append(0xea);
    arr.append(0x10);
    arr.append(0x86);
    arr.append(0x19);
    arr.append(0x7d);
    arr.append(0xd9);
    
    let res = rlp_decode(arr.span()).unwrap();
    assert(res.len() == 1, 'Wrong len');

    arr.pop_front();
    arr.pop_front();
    let expected_item = RLPItem::Bytes(arr.span());

    assert(res.at(0) == @expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_long_string_len_of_len_2() {
    let mut arr = ArrayTrait::new();
    arr.append(0xb9);
    arr.append(0x01);
    arr.append(0x02);
    arr.append(0xf7);
    arr.append(0xa1);
    arr.append(0x7e);
    arr.append(0xf9);
    arr.append(0x59);
    arr.append(0xd4);
    arr.append(0x88);
    arr.append(0x38);
    arr.append(0x8d);
    arr.append(0xdc);
    arr.append(0x34);
    arr.append(0x7b);
    arr.append(0x3a);
    arr.append(0x10);
    arr.append(0xdd);
    arr.append(0x85);
    arr.append(0x43);
    arr.append(0x1d);
    arr.append(0x0c);
    arr.append(0x37);
    arr.append(0x98);
    arr.append(0x6a);
    arr.append(0x63);
    arr.append(0xbd);
    arr.append(0x18);
    arr.append(0xba);
    arr.append(0xa3);
    arr.append(0x8d);
    arr.append(0xb1);
    arr.append(0xa4);
    arr.append(0x81);
    arr.append(0x6f);
    arr.append(0x24);
    arr.append(0xde);
    arr.append(0xc3);
    arr.append(0xec);
    arr.append(0x16);
    arr.append(0x6e);
    arr.append(0xb3);
    arr.append(0xb2);
    arr.append(0xac);
    arr.append(0xc4);
    arr.append(0xc4);
    arr.append(0xf7);
    arr.append(0x79);
    arr.append(0x04);
    arr.append(0xba);
    arr.append(0x76);
    arr.append(0x3c);
    arr.append(0x67);
    arr.append(0xc6);
    arr.append(0xd0);
    arr.append(0x53);
    arr.append(0xda);
    arr.append(0xea);
    arr.append(0x10);
    arr.append(0x86);
    arr.append(0x19);
    arr.append(0x7d);
    arr.append(0xd9);
    arr.append(0x33);
    arr.append(0x58);
    arr.append(0x47);
    arr.append(0x69);
    arr.append(0x34);
    arr.append(0x76);
    arr.append(0x89);
    arr.append(0x43);
    arr.append(0x67);
    arr.append(0x93);
    arr.append(0x45);
    arr.append(0x76);
    arr.append(0x87);
    arr.append(0x34);
    arr.append(0x95);
    arr.append(0x67);
    arr.append(0x89);
    arr.append(0x34);
    arr.append(0x36);
    arr.append(0x43);
    arr.append(0x86);
    arr.append(0x79);
    arr.append(0x43);
    arr.append(0x63);
    arr.append(0x34);
    arr.append(0x78);
    arr.append(0x63);
    arr.append(0x49);
    arr.append(0x58);
    arr.append(0x67);
    arr.append(0x83);
    arr.append(0x59);
    arr.append(0x64);
    arr.append(0x56);
    arr.append(0x37);
    arr.append(0x93);
    arr.append(0x74);
    arr.append(0x58);
    arr.append(0x69);
    arr.append(0x69);
    arr.append(0x43);
    arr.append(0x67);
    arr.append(0x39);
    arr.append(0x48);
    arr.append(0x67);
    arr.append(0x98);
    arr.append(0x45);
    arr.append(0x63);
    arr.append(0x89);
    arr.append(0x45);
    arr.append(0x67);
    arr.append(0x94);
    arr.append(0x37);
    arr.append(0x63);
    arr.append(0x04);
    arr.append(0x56);
    arr.append(0x40);
    arr.append(0x39);
    arr.append(0x68);
    arr.append(0x43);
    arr.append(0x08);
    arr.append(0x68);
    arr.append(0x40);
    arr.append(0x65);
    arr.append(0x03);
    arr.append(0x46);
    arr.append(0x80);
    arr.append(0x93);
    arr.append(0x48);
    arr.append(0x64);
    arr.append(0x95);
    arr.append(0x36);
    arr.append(0x87);
    arr.append(0x39);
    arr.append(0x84);
    arr.append(0x56);
    arr.append(0x73);
    arr.append(0x76);
    arr.append(0x89);
    arr.append(0x34);
    arr.append(0x95);
    arr.append(0x86);
    arr.append(0x73);
    arr.append(0x65);
    arr.append(0x40);
    arr.append(0x93);
    arr.append(0x60);
    arr.append(0x98);
    arr.append(0x34);
    arr.append(0x56);
    arr.append(0x83);
    arr.append(0x04);
    arr.append(0x56);
    arr.append(0x80);
    arr.append(0x36);
    arr.append(0x08);
    arr.append(0x59);
    arr.append(0x68);
    arr.append(0x45);
    arr.append(0x06);
    arr.append(0x83);
    arr.append(0x06);
    arr.append(0x68);
    arr.append(0x40);
    arr.append(0x59);
    arr.append(0x68);
    arr.append(0x40);
    arr.append(0x65);
    arr.append(0x84);
    arr.append(0x03);
    arr.append(0x68);
    arr.append(0x30);
    arr.append(0x48);
    arr.append(0x65);
    arr.append(0x03);
    arr.append(0x46);
    arr.append(0x83);
    arr.append(0x49);
    arr.append(0x57);
    arr.append(0x68);
    arr.append(0x95);
    arr.append(0x79);
    arr.append(0x68);
    arr.append(0x34);
    arr.append(0x76);
    arr.append(0x83);
    arr.append(0x74);
    arr.append(0x69);
    arr.append(0x87);
    arr.append(0x43);
    arr.append(0x59);
    arr.append(0x63);
    arr.append(0x84);
    arr.append(0x75);
    arr.append(0x63);
    arr.append(0x98);
    arr.append(0x47);
    arr.append(0x56);
    arr.append(0x34);
    arr.append(0x86);
    arr.append(0x73);
    arr.append(0x94);
    arr.append(0x87);
    arr.append(0x65);
    arr.append(0x43);
    arr.append(0x98);
    arr.append(0x67);
    arr.append(0x34);
    arr.append(0x96);
    arr.append(0x79);
    arr.append(0x34);
    arr.append(0x86);
    arr.append(0x57);
    arr.append(0x93);
    arr.append(0x48);
    arr.append(0x57);
    arr.append(0x69);
    arr.append(0x34);
    arr.append(0x87);
    arr.append(0x56);
    arr.append(0x89);
    arr.append(0x34);
    arr.append(0x57);
    arr.append(0x68);
    arr.append(0x73);
    arr.append(0x49);
    arr.append(0x56);
    arr.append(0x53);
    arr.append(0x79);
    arr.append(0x43);
    arr.append(0x95);
    arr.append(0x67);
    arr.append(0x34);
    arr.append(0x96);
    arr.append(0x79);
    arr.append(0x38);
    arr.append(0x47);
    arr.append(0x63);
    arr.append(0x94);
    arr.append(0x65);
    arr.append(0x37);
    arr.append(0x89);
    arr.append(0x63);
    arr.append(0x53);
    arr.append(0x45);
    arr.append(0x68);
    arr.append(0x79);
    arr.append(0x88);
    arr.append(0x97);
    arr.append(0x68);
    arr.append(0x87);
    arr.append(0x68);
    arr.append(0x68);
    arr.append(0x68);
    arr.append(0x76);
    arr.append(0x99);
    arr.append(0x87);
    arr.append(0x60);
    
    let res = rlp_decode(arr.span()).unwrap();
    assert(res.len() == 1, 'Wrong len');

    arr.pop_front();
    arr.pop_front();
    arr.pop_front();
    let expected_item = RLPItem::Bytes(arr.span());

    assert(res.at(0) == @expected_item, 'Wrong value');
}
