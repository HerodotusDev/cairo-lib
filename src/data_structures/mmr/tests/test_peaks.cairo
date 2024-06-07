use cairo_lib::data_structures::mmr::peaks::PeaksTrait;
use cairo_lib::hashing::poseidon::PoseidonHasher;

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
    let expected_bag = PoseidonHasher::hash_double(
        peak0, PoseidonHasher::hash_double(peak1, peak2)
    );
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
    let root = PoseidonHasher::hash_double(last_pos, bag);

    assert(peaks.span().valid(last_pos.into(), root), 'Valid');
}
