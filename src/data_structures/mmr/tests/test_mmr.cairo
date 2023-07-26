use cairo_lib::data_structures::mmr::mmr::{MMR, MMRTrait};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use array::{ArrayTrait, SpanTrait};
use result::ResultTrait;

fn helper_test_get_elements() -> Span<felt252>{
    let elem1 = PoseidonHasher::hash_double(1, 1);
    let elem2 = PoseidonHasher::hash_double(2, 2);
    let elem3 = PoseidonHasher::hash_double(3, PoseidonHasher::hash_double(elem1, elem2));
    let elem4 = PoseidonHasher::hash_double(4, 4);
    let elem5 = PoseidonHasher::hash_double(5, 5);
    let elem6 = PoseidonHasher::hash_double(6, PoseidonHasher::hash_double(elem4, elem5));
    let elem7 = PoseidonHasher::hash_double(7, PoseidonHasher::hash_double(elem3, elem6));
    let elem8 = PoseidonHasher::hash_double(8, 8);

    let arr = array![elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8];
    arr.span()
}

#[test]
#[available_gas(99999999)]
fn test_append_initial() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let peaks = array![].span();
    mmr.append(1, peaks);

    let root = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(mmr.last_pos == 1, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_1() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let mut peaks = array![].span();
    mmr.append(1, peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(2, peaks);

    let root = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(mmr.last_pos == 3, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_2() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let mut peaks = array![].span();
    mmr.append(1, peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(2, peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(4, peaks);

    let root = PoseidonHasher::hash_double(4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3)));
    assert(mmr.last_pos == 4, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_3() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let mut peaks = array![].span();
    mmr.append(1, peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(2, peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(4, peaks);

    peaks = array![*elems.at(2), *elems.at(3)].span();
    mmr.append(5, peaks);

    let root = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(mmr.last_pos == 7, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_4() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let mut peaks = array![].span();
    mmr.append(1, peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(2, peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(4, peaks);

    peaks = array![*elems.at(2), *elems.at(3)].span();
    mmr.append(5, peaks);

    peaks = array![*elems.at(6)].span();
    mmr.append(8, peaks);

    let root = PoseidonHasher::hash_double(8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7)));
    assert(mmr.last_pos == 8, 'Wrong last_pos');
    assert(mmr.root == root, 'Wrong root');
}

#[test]
#[available_gas(99999999)]
fn test_append_wrong_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr = MMRTrait::new();
    
    let mut peaks = array![].span();
    mmr.append(1, peaks);

    peaks = array![*elems.at(0)].span();
    mmr.append(2, peaks);

    peaks = array![*elems.at(2)].span();
    mmr.append(4, peaks);

    peaks = array![*elems.at(2), *elems.at(4)].span();
    let res = mmr.append(5, peaks);

    assert(res.is_err(), 'Wrong peaks');
}
