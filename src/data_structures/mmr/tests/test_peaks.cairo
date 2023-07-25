use cairo_lib::data_structures::mmr::peaks::PeaksTrait;
use cairo_lib::hashing::poseidon::PoseidonHasher;
use array::ArrayTrait;
use traits::Into;

#[test]
#[available_gas(99999999)]
fn test_bag_peaks_1() {
    let peak0 = PoseidonHasher::hash_double(1, 1);
    let peaks = array![peak0];

    let bag = peaks.span().bag();
    assert(bag == peak0, 'Bag 1 peak')
}

#[test]
#[available_gas(99999999)]
fn test_bag_peaks_2() {
    let peak0 = PoseidonHasher::hash_double(1, 287388);
    let peak1 = PoseidonHasher::hash_double(7, 827394299);
    let peaks = array![peak0, peak1];

    let bag = peaks.span().bag();
    let expected_bag = PoseidonHasher::hash_double(peak0, peak1);
    assert(bag == expected_bag, 'Bag 2 peaks')
}

#[test]
#[available_gas(99999999)]
fn test_bag_peaks_3() {
    let peak0 = PoseidonHasher::hash_double(245, 287388);
    let peak1 = PoseidonHasher::hash_double(2340, 827394299);
    let peak2 = PoseidonHasher::hash_double(923048, 23984294798);
    let peaks = array![peak0, peak1, peak2];

    let bag = peaks.span().bag();
    let expected_bag = PoseidonHasher::hash_double(peak0, PoseidonHasher::hash_double(peak1, peak2));
    assert(bag == expected_bag, 'Bag 3 peaks')
}

#[test]
#[available_gas(99999999)]
fn test_valid() {
    let peak0 = PoseidonHasher::hash_double(245, 287388);
    let peak1 = PoseidonHasher::hash_double(2340, 827394299);
    let peak2 = PoseidonHasher::hash_double(923048, 23984294798);
    let peaks = array![peak0, peak1, peak2];

    let bag = peaks.span().bag();
    let last_pos = 923048;
    let last_pos_u32 = 923048_u32;
    let root = PoseidonHasher::hash_double(last_pos, bag);

    assert(peaks.span().valid(last_pos_u32, root), 'Valid');
}

#[test]
#[available_gas(99999999)]
fn test_containts_peak() {
    let peak0 = PoseidonHasher::hash_double(245, 287388);
    let peak1 = PoseidonHasher::hash_double(2340, 827394299);
    let peak2 = PoseidonHasher::hash_double(923048, 23984294798);

    let peaks_arr = array![peak0, peak1, peak2];
    let peaks = peaks_arr.span();

    assert(peaks.contains_peak(peak0), 'Contains peak 0');
    assert(peaks.contains_peak(peak1), 'Contains peak 1');
    assert(peaks.contains_peak(peak2), 'Contains peak 2');

    assert(!peaks.contains_peak(0), 'Does not contain 0');
    assert(!peaks.contains_peak(1), 'Does not contain 1');
}
