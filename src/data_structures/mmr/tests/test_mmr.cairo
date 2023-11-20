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
    mmr.append(*elems.at(0), peaks);

    let root = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(mmr.last_pos == 1, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_1() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let mut peaks = array![].span();
    mmr.append(*elems.at(0), peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(*elems.at(1), peaks);

    let root = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(mmr.last_pos == 3, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_2() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let mut peaks = array![].span();
    mmr.append(*elems.at(0), peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(*elems.at(1), peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(*elems.at(3), peaks);

    let root = PoseidonHasher::hash_double(
        4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3))
    );
    assert(mmr.last_pos == 4, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_3() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let mut peaks = array![].span();
    mmr.append(*elems.at(0), peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(*elems.at(1), peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(*elems.at(3), peaks);

    peaks = array![*elems.at(2), *elems.at(3)].span();
    mmr.append(*elems.at(4), peaks);

    let root = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(mmr.last_pos == 7, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_4() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let mut peaks = array![].span();
    mmr.append(*elems.at(0), peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(*elems.at(1), peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(*elems.at(3), peaks);

    peaks = array![*elems.at(2), *elems.at(3)].span();
    mmr.append(*elems.at(4), peaks);

    peaks = array![*elems.at(6)].span();
    mmr.append(*elems.at(7), peaks);

    let root = PoseidonHasher::hash_double(
        8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
    );
    assert(mmr.last_pos == 8, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_wrong_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let mut peaks = array![].span();
    mmr.append(*elems.at(0), peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(*elems.at(1), peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(*elems.at(3), peaks);

    peaks = array![*elems.at(2), *elems.at(4)].span();
    let res = mmr.append(*elems.at(4), peaks);

    assert(res.is_err(), 'Wrong peaks');
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
    mmr_real.append(9, peaks_real);

    // add the next element abnormally to mmr_real and get the root;
    let forged_peak = PoseidonHasher::hash_double(*elems.at(6), *elems.at(7));
    let peaks_fake = array![forged_peak].span();
    let res = mmr_fake.append(9, peaks_fake);

    assert(res.is_err(), 'attack success: forged peak');
}
