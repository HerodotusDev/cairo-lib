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

//#[test]
//#[available_gas(99999999)]
//fn test_rlp_decode_word64_short_string() {
    //let mut arr = 0x9b5a806cf634c0398d8f2d89fd49a91ef33da474cd8494
        //0xbb,
        //0xa8,
        //0xda,
        //0x3b,
        //0xf7
    //];

    //let (res, len) = rlp_decode(arr.span()).unwrap();
    //assert(len == 1 + (0x9b - 0x80), 'Wrong len');

    //arr.pop_front();
    //let expected_item = RLPItem::Bytes(arr.span());

    //assert(res == expected_item, 'Wrong value');
//}
