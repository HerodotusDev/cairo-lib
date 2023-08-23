use cairo_lib::encoding::rlp_word64::{RLPItemWord64, rlp_decode_word64};
use cairo_lib::utils::bitwise::reverse_endianness;
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
    //let mut arr = array![
        //0x9b,
        //0x5a,
        //0x80,
        //0x6c,
        //0xf6,
        //0x34,
        //0xc0,
        //0x39,
        //0x8d,
        //0x8f,
        //0x2d,
        //0x89,
        //0xfd,
        //0x49,
        //0xa9,
        //0x1e,
        //0xf3,
        //0x3d,
        //0xa4,
        //0x74,
        //0xcd,
        //0x84,
        //0x94,
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
