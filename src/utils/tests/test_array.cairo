use array::ArrayTrait;
use cairo_lib::utils::array::{array_contains};

#[test]
#[available_gas(10000000)]
fn test_array_contains() {
    let mut arr: Array<felt252> = Default::default();
    arr.append(0);
    arr.append(1);
    arr.append(2);

    assert(array_contains(0, arr.span()), 'array contains 0');
    assert(array_contains(1, arr.span()), 'array contains 1');
    assert(array_contains(2, arr.span()), 'array contains 2');
    assert(!array_contains(3, arr.span()), 'array does not contain 3');
}

#[test]
#[available_gas(200000)]
fn test_array_does_not_contain() {
    let arr: Array<felt252> = Default::default();
    assert(!array_contains(0, arr.span()), 'array does not contain 0');
}

