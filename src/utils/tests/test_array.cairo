use cairo_lib::utils::array::span_contains;
use array::ArrayTrait;

#[test]
#[available_gas(999999)]
fn test_span_contains() {
    let arr = array![1, 2, 3, 4, 5];
    let span = arr.span();

    assert(span_contains(span, 1), 'contains 1');
    assert(span_contains(span, 2), 'contains 2');
    assert(span_contains(span, 3), 'contains 3');
    assert(span_contains(span, 4), 'contains 4');
    assert(span_contains(span, 5), 'contains 5');
    assert(!span_contains(span, 0), 'does not contain 0');
    assert(!span_contains(span, 6), 'does not contain 6');
}
