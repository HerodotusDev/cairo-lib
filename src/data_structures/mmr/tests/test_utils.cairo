use cairo_lib::data_structures::mmr::utils::{get_height, compute_root};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use array::ArrayTrait;

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

#[test]
#[available_gas(99999999)]
fn test_compute_root() {
    let peak0 = PoseidonHasher::hash_double(245, 287388);
    let peak1 = PoseidonHasher::hash_double(2340, 827394299);
    let peak2 = PoseidonHasher::hash_double(923048, 23984294798);
    let peaks = array![peak0, peak1, peak2];

    let bag = peaks.span().bag();
    let last_pos = 923048;
    let root = PoseidonHasher::hash_double(last_pos, bag);
    let computed_root = compute_root(last_pos, peaks.span());

    assert(root == computed_root, 'Roots not matching');
}
