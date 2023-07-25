use cairo_lib::data_structures::mmr::utils::get_height;

#[test]
#[available_gas(99999999)]
fn test_get_height() {
    assert(get_height(1) == 0, 'get_height 1');
    assert(get_height(2) == 0, 'get_height 2');
    assert(get_height(3) == 1, 'get_height 3');
    assert(get_height(7) == 2, 'get_height 7');
    assert(get_height(8) == 0, 'get_height 8');
    assert(get_height(46) == 3, 'get_height 46');
    assert(get_height(49) == 1, 'get_height 49');
}
