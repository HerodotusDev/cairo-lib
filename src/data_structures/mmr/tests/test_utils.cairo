use cairo_lib::data_structures::mmr::utils::height;

#[test]
#[available_gas(99999999)]
fn test_height() {
    assert(height(1) == 0, 'height 1');
    assert(height(2) == 0, 'height 2');
    assert(height(3) == 1, 'height 3');
    assert(height(7) == 2, 'height 7');
    assert(height(8) == 0, 'height 8');
    assert(height(46) == 3, 'height 46');
    assert(height(49) == 1, 'height 49');
}
