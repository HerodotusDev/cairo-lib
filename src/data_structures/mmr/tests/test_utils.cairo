use cairo_lib::data_structures::mmr::utils::{
    get_height, compute_root, count_ones, leaf_index_to_mmr_index, get_peak_info,
    mmr_size_to_leaf_count,
};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::peaks::PeaksTrait;

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

#[test]
#[available_gas(999999999)]
fn test_count_ones() {
    assert(count_ones(1) == 1, 'count_ones(1) != 1');
    assert(count_ones(2) == 1, 'count_ones(2) != 1');
    assert(count_ones(3) == 2, 'count_ones(3) != 2');
    assert(count_ones(4) == 1, 'count_ones(4) != 1');
    assert(count_ones(5) == 2, 'count_ones(5) != 2');
    assert(count_ones(6) == 2, 'count_ones(6) != 2');
    assert(count_ones(7) == 3, 'count_ones(7) != 3');
    assert(count_ones(8) == 1, 'count_ones(8) != 1');
    assert(count_ones(9) == 2, 'count_ones(9) != 2');
    assert(count_ones(10) == 2, 'count_ones(10) != 2');
    assert(count_ones(11) == 3, 'count_ones(11) != 3');
    assert(count_ones(12) == 2, 'count_ones(12) != 2');
    assert(count_ones(13) == 3, 'count_ones(13) != 3');
    assert(count_ones(14) == 3, 'count_ones(14) != 3');
    assert(count_ones(15) == 4, 'count_ones(15) != 4');
    assert(count_ones(16) == 1, 'count_ones(16) != 1');
    assert(count_ones(17) == 2, 'count_ones(17) != 2');
    assert(count_ones(18) == 2, 'count_ones(18) != 2');
    assert(count_ones(19) == 3, 'count_ones(19) != 3');
    assert(count_ones(20) == 2, 'count_ones(20) != 2');
}

#[test]
#[available_gas(999999999)]
fn test_leaf_index_to_mmr_index() {
    assert(leaf_index_to_mmr_index(1) == 1, 'leaf_..._index(1) != 1');
    assert(leaf_index_to_mmr_index(2) == 2, 'leaf_..._index(2) != 2');
    assert(leaf_index_to_mmr_index(3) == 4, 'leaf_..._index(3) != 4');
    assert(leaf_index_to_mmr_index(4) == 5, 'leaf_..._index(4) != 5');
    assert(leaf_index_to_mmr_index(5) == 8, 'leaf_..._index(5) != 8');
    assert(leaf_index_to_mmr_index(6) == 9, 'leaf_..._index(6) != 9');
    assert(leaf_index_to_mmr_index(7) == 11, 'leaf_..._index(7) != 11');
    assert(leaf_index_to_mmr_index(8) == 12, 'leaf_..._index(8) != 12');
    assert(leaf_index_to_mmr_index(9) == 16, 'leaf_..._index(9) != 16');
    assert(leaf_index_to_mmr_index(10) == 17, 'leaf_..._index(10) != 17');
    assert(leaf_index_to_mmr_index(11) == 19, 'leaf_..._index(11) != 19');
}

#[test]
#[available_gas(999999999)]
fn test_mmr_size_to_leaf_count() {
    assert(mmr_size_to_leaf_count(1) == 1, 'mmr_size_to_leaf_count(1) != 1');
    assert(mmr_size_to_leaf_count(3) == 2, 'mmr_size_to_leaf_count(3) != 2');
    assert(mmr_size_to_leaf_count(4) == 3, 'mmr_size_to_leaf_count(4) != 3');
    assert(mmr_size_to_leaf_count(7) == 4, 'mmr_size_to_leaf_count(7) != 4');
    assert(mmr_size_to_leaf_count(8) == 5, 'mmr_size_to_leaf_count(8) != 5');
    assert(mmr_size_to_leaf_count(10) == 6, 'mmr_size_to_leaf_count(10) != 6');
    assert(mmr_size_to_leaf_count(11) == 7, 'mmr_size_to_leaf_count(11) != 7');
    assert(mmr_size_to_leaf_count(15) == 8, 'mmr_size_to_leaf_count(15) != 8');
}

#[test]
#[available_gas(999999999)]
fn test_get_peak_info() {
    assert(get_peak_info(11, 11) == (2, 0), 'get_peak_info(11, 11) != (2, 0)');
    assert(get_peak_info(15, 11) == (0, 3), 'get_peak_info(15, 11) != (0, 3)');
    assert(get_peak_info(18, 16) == (1, 1), 'get_peak_info(18, 16) != (1, 1)');
    assert(get_peak_info(26, 16) == (1, 2), 'get_peak_info(26, 16) != (1, 2)');
    assert(get_peak_info(26, 16) == (1, 2), 'get_peak_info(26, 16) != (1, 2)');
    assert(get_peak_info(31, 16) == (0, 4), 'get_peak_info(31, 16) != (0, 4)');
}
