use cairo_lib::data_structures::mmr::mmr::{MMR, MMRTrait};
use cairo_lib::hashing::poseidon::PoseidonHasher;

fn helper_test_get_elements() -> Span<felt252> {
    let elem1 = PoseidonHasher::hash_single(1);
    let elem2 = PoseidonHasher::hash_single(2);
    let elem3 = PoseidonHasher::hash_double(elem1, elem2);
    let elem4 = PoseidonHasher::hash_single(4);
    let elem5 = PoseidonHasher::hash_single(5);
    let elem6 = PoseidonHasher::hash_double(elem4, elem5);
    let elem7 = PoseidonHasher::hash_double(elem3, elem6);
    let elem8 = PoseidonHasher::hash_single(8);

    let arr = array![elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8];
    arr.span()
}

#[test]
#[available_gas(99999999)]
fn test_append_initial() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let peaks = array![].span();
    let (new_root, new_peaks) = mmr.append(*elems.at(0), peaks).unwrap();

    let expected_root = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(mmr.last_pos == 1, 'Wrong last_pos');
    assert(mmr.root == expected_root, 'Wrong updated root');
    assert(new_root == expected_root, 'Wrong returned root');

    assert(new_peaks == array![*elems.at(0)].span(), 'Wrong new_peaks');
}

#[test]
#[available_gas(99999999)]
fn test_append_1() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    assert(mmr.last_pos == 3, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_2() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3)));
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    assert(mmr.last_pos == 4, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_3() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3)));
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    let (mmr_root_4, mmr_peaks_4) = mmr.append(*elems.at(4), mmr_peaks_3).unwrap();

    let expected_peaks_4 = array![*elems.at(6)].span();
    let expected_root_4 = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(expected_peaks_4 == mmr_peaks_4, 'Wrong peaks after 4 appends');
    assert(mmr.root == expected_root_4, 'Wrong updated root after 4 a.');
    assert(mmr_root_4 == expected_root_4, 'Wrong reeturned root after 4 a.');

    assert(mmr.last_pos == 7, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_4() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3)));
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    let (mmr_root_4, mmr_peaks_4) = mmr.append(*elems.at(4), mmr_peaks_3).unwrap();

    let expected_peaks_4 = array![*elems.at(6)].span();
    let expected_root_4 = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(expected_peaks_4 == mmr_peaks_4, 'Wrong peaks after 4 appends');
    assert(mmr.root == expected_root_4, 'Wrong updated root after 4 a.');
    assert(mmr_root_4 == expected_root_4, 'Wrong reeturned root after 4 a.');

    let (mmr_root_5, mmr_peaks_5) = mmr.append(*elems.at(7), mmr_peaks_4).unwrap();

    let expected_peaks_5 = array![*elems.at(6), *elems.at(7)].span();
    let expected_root_5 = PoseidonHasher::hash_double(8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7)));
    assert(expected_peaks_5 == mmr_peaks_5, 'Wrong peaks after 5 appends');
    assert(mmr.root == expected_root_5, 'Wrong updated root after 5 a.');
    assert(mmr_root_5 == expected_root_5, 'Wrong reeturned root after 5 a.');

    assert(mmr.last_pos == 8, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_wrong_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let peaks = array![].span();

    let (_, peaks) = mmr.append(*elems.at(0), peaks).unwrap();

    let (_, peaks) = mmr.append(*elems.at(1), peaks).unwrap();

    let (_, peaks) = mmr.append(*elems.at(3), peaks).unwrap();

    assert(peaks == array![*elems.at(2), *elems.at(3)].span(), 'Wrong peaks returned by append');

    let wrong_peaks = array![*elems.at(2), *elems.at(4)].span();
    let res = mmr.append(*elems.at(4), wrong_peaks);

    assert(res.is_err(), 'Appnd accepted with wrong peaks');
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_all_left() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(1), *elems.at(5)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(mmr.verify_proof(1, *elems.at(0), peaks, proof).unwrap(), 'Invalid proof all left')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_all_right() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(3), *elems.at(2)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(mmr.verify_proof(5, *elems.at(4), peaks, proof).unwrap(), 'Invalid proof all right')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_left_right() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(0), *elems.at(5)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(
        mmr.verify_proof(2, *elems.at(1), peaks, proof).unwrap(), 'Valid invalid proof left right'
    )
}

#[test]
#[available_gas(99999999)]
fn test_verify_invalid_proof() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(2), *elems.at(2)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(!mmr.verify_proof(2, *elems.at(1), peaks, proof).unwrap(), 'Invalid proof left right')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_invalid_peaks() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(0), *elems.at(5)].span();
    let peaks = array![*elems.at(1), *elems.at(5)].span();

    assert(mmr.verify_proof(2, *elems.at(1), peaks, proof).is_err(), 'Proof wrong peaks')
}

#[test]
#[available_gas(99999999)]
fn test_attack_forge_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr_real: MMR = MMRTrait::new(
        0x21aea73dea77022a4882e1f656b76c9195161ed1cff2b065a74d7246b02d5d6, 0x8
    );
    let mut mmr_fake: MMR = MMRTrait::new(
        0x21aea73dea77022a4882e1f656b76c9195161ed1cff2b065a74d7246b02d5d6, 0x8
    );

    // add the next element normally to mmr_real and get the root;
    let peaks_real = array![*elems.at(6), *elems.at(7)].span();
    let _ = mmr_real.append(9, peaks_real);

    // add the next element abnormally to mmr_real and get the root;
    let forged_peak = PoseidonHasher::hash_double(*elems.at(6), *elems.at(7));
    let peaks_fake = array![forged_peak].span();
    let res = mmr_fake.append(9, peaks_fake);

    assert(res.is_err(), 'attack success: forged peak');
}
