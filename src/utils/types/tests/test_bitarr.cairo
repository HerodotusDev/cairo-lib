use cairo_lib::utils::types::bitarr::{BitArr, BitArrTryIntoFelt252};
use traits::TryInto;
use option::OptionTrait;
use array::ArrayTrait;

#[test]
#[available_gas(999999999)]
fn test_bitarr_try_into_felt252() {
    let val_0 = array![].span();
    assert(val_0.try_into().unwrap() == 0, '0');

    let val_1 = array![true].span();
    assert(val_1.try_into().unwrap() == 1, '1');

    let val_2 = array![true, false].span();
    assert(val_2.try_into().unwrap() == 2, '2');

    let val_3 = array![true, false, true].span();
    assert(val_3.try_into().unwrap() == 5, '5');

    let val_4 = array![true, false, true, false].span();
    assert(val_4.try_into().unwrap() == 10, '10');

    let val_5 = array![true, false, true, false, true].span();
    assert(val_5.try_into().unwrap() == 21, '21');
}

#[test]
#[available_gas(999999999)]
fn test_bitarr_try_into_felt252_long() {
    let mut arr = ArrayTrait::new();
    let mut i: usize = 0;
    loop {
        if i == 254 {
            break;
        }
        arr.append(true);
        i += 1;
    };

    let val: Option<felt252> = arr.span().try_into();
    assert(val.is_none(), 'none');
}
