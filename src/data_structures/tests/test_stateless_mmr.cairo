use core::result::ResultTrait;
use array::ArrayTrait;
use core::option::OptionTrait;
use cairo_lib::data_structures::stateless_mmr::{StatelessMmrTrait};
use cairo_lib::hashing::poseidon::PoseidonHasher;

// test_stateless_mmr append
#[test]
#[available_gas(2000000)]
fn test_append_initial() -> (felt252, felt252, felt252) {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let node1 = PoseidonHasher::hash_double(1, 1);

    let (new_pos, new_root, new_peaks) = stateless_mmr.append(1, peaks, 0, 0);
    assert(new_pos == 1, 'new position should be 1');
    let expected_root = PoseidonHasher::hash_double(1, node1);
    assert(new_root == expected_root, 'new root should hash of node');

    let expected_root_method2 = StatelessMmrTrait::compute_root(new_peaks.span(), new_pos).unwrap();
    assert(new_root == expected_root_method2, 'new root should hash of node');
    return (new_pos, new_root, node1);
}

#[test]
#[available_gas(20000000)]
fn test_append_one() -> (felt252, felt252, felt252) {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let node1 = PoseidonHasher::hash_double(1, 1);
    let (last_pos, last_root, last_peaks) = stateless_mmr.append(1, peaks, 0, 0);

    assert(last_pos == 1, 'new position should be 1');
    let expected_root = PoseidonHasher::hash_double(1, node1);
    assert(last_root == expected_root, 'new root should hash of node');

    let expected_root_method2 = StatelessMmrTrait::compute_root(last_peaks.span(), last_pos)
        .unwrap();
    assert(last_root == expected_root_method2, 'new root should hash of node');

    let (new_pos, new_root, new_arr) = stateless_mmr.append(2, last_peaks, last_pos, last_root);
    assert(new_pos == 3, 'new position should be 3');

    let node2 = PoseidonHasher::hash_double(2, 2);
    let node3_1 = PoseidonHasher::hash_double(node1, node2);
    let node3 = PoseidonHasher::hash_double(3, node3_1);
    let expected_root = PoseidonHasher::hash_double(3, node3);

    assert(new_root == expected_root, 'new root should hash of node');
    return (new_pos, new_root, node3);
}

#[test]
#[available_gas(400000000)]
fn test_append_two() -> (felt252, felt252, Array<felt252>) {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();

    let (last_pos_1, last_root_1, last_peaks_1) = stateless_mmr.append(1, peaks, 0, 0);
    let (last_pos_2, last_root_2, last_peaks_2) = stateless_mmr
        .append(2, last_peaks_1, last_pos_1, last_root_1);

    // calculate node3
    let node1 = PoseidonHasher::hash_double(1, 1);
    let node2 = PoseidonHasher::hash_double(2, 2);
    let node3_1 = PoseidonHasher::hash_double(node1, node2);
    let node3 = PoseidonHasher::hash_double(3, node3_1);
    let mut new_blank_peaks: Array<felt252> = Default::default();
    new_blank_peaks.append(node3);

    let (new_pos, new_root, new_peaks) = stateless_mmr
        .append(4, new_blank_peaks, last_pos_2, last_root_2);

    assert(new_pos == 4, 'new position should be 4');

    let expected_root = StatelessMmrTrait::compute_root(new_peaks.span(), new_pos).unwrap();
    assert(new_root == expected_root, 'new root should hash of node');
    return (new_pos, new_root, new_peaks);
}

#[test]
#[available_gas(100000000)]
fn test_append_three() -> (felt252, felt252, Array<felt252>) {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, last_peaks) = test_append_two();
    let last_peaks_0 = *last_peaks.at(0);
    let last_peaks_1 = *last_peaks.at(1);

    let (new_pos, new_root, new_peaks) = stateless_mmr.append(5, last_peaks, last_pos, last_root);
    assert(new_pos == 7, 'new position should be 7');

    let node5 = PoseidonHasher::hash_double(5, 5);
    let node6_1 = PoseidonHasher::hash_double(last_peaks_1, node5);
    let node6 = PoseidonHasher::hash_double(6, node6_1);
    let node7_1 = PoseidonHasher::hash_double(last_peaks_0, node6);
    let node7 = PoseidonHasher::hash_double(7, node7_1);

    let mut peaks: Array<felt252> = Default::default();
    peaks.append(node7);

    let expected_root = StatelessMmrTrait::compute_root(peaks.span(), new_pos).unwrap();
    assert(new_root == expected_root, 'new root should hash of node');
    return (new_pos, new_root, peaks);
}

#[test]
#[available_gas(200000000)]
fn test_append_four() -> (felt252, felt252, Array<felt252>) {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, mut last_peaks) = test_append_three();
    let (test_pos, test_root, mut test_peaks) = test_append_three();

    let (new_pos, new_root, new_peaks) = stateless_mmr.append(8, last_peaks, last_pos, last_root);
    assert(new_pos == 8, 'new position should be 8');

    let node8 = PoseidonHasher::hash_double(8, 8);
    test_peaks.append(node8);
    let expected_root = StatelessMmrTrait::compute_root(test_peaks.span(), new_pos).unwrap();
    assert(new_root == expected_root, 'new root should hash of node');
    return (new_pos, new_root, new_peaks);
}

// test_stateless_mmr append
#[test]
#[available_gas(400000000)]
fn test_multi_append_single_element() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut elems: Array<felt252> = Default::default();
    elems.append(1);
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_arr) = stateless_mmr.multi_append(elems, peaks, 0, 0);

    assert(new_pos == 1, 'new_pos should be 1');
}

#[test]
#[available_gas(400000000)]
fn test_multi_append_two_elements() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut elems: Array<felt252> = Default::default();
    elems.append(1);
    elems.append(2);
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_arr) = stateless_mmr.multi_append(elems, peaks, 0, 0);
    assert(new_pos == 3, 'new_pos should be 3');
}

#[test]
#[available_gas(400000000)]
fn test_multi_append_three_elements() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut elems: Array<felt252> = Default::default();
    elems.append(1);
    elems.append(2);
    elems.append(3);
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_arr) = stateless_mmr.multi_append(elems, peaks, 0, 0);
    assert(new_pos == 4, 'new_pos should be 4');
}

#[test]
#[available_gas(400000000)]
fn test_multi_append_four_elements() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut elems: Array<felt252> = Default::default();
    elems.append(1);
    elems.append(2);
    elems.append(3);
    elems.append(4);
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_arr) = stateless_mmr.multi_append(elems, peaks, 0, 0);
    assert(new_pos == 7, 'new_pos should be 7');
}

#[test]
#[available_gas(400000000)]
fn test_multi_append_five_elements() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut elems: Array<felt252> = Default::default();
    elems.append(1);
    elems.append(2);
    elems.append(3);
    elems.append(4);
    elems.append(5);
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_arr) = stateless_mmr.multi_append(elems, peaks, 0, 0);
    assert(new_pos == 8, 'new_pos should be 8');
}

// test_stateless_mmr verify
#[test]
#[available_gas(40000000)]
fn test_verify_proof_one_leaf() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_peaks) = stateless_mmr.append(1, peaks, 0, 0);
    assert(new_pos == 1, 'new_pos should be 1');
    let result = stateless_mmr
        .verify_proof(1, 1, ArrayTrait::new(), new_peaks, new_pos, new_root)
        .unwrap();
    assert(result, 'verify_proof should return true');
}


#[test]
#[available_gas(40000000)]
fn test_verify_proof_two_leaf() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos_1, new_root_1, new_peaks_1) = stateless_mmr.append(1, peaks, 0, 0);
    let (new_pos_2, new_root_2, new_peaks_2) = stateless_mmr
        .append(2, new_peaks_1, new_pos_1, new_root_1);
    let node1 = PoseidonHasher::hash_double(1, 1);
    assert(new_pos_2 == 3, 'new_pos should be 3');
    let mut proof: Array<felt252> = Default::default();
    proof.append(node1);
    let result = stateless_mmr
        .verify_proof(2, 2, proof, new_peaks_2, new_pos_2, new_root_2)
        .unwrap();
    assert(result, 'verify_proof should return true');
}


#[test]
#[available_gas(40000000)]
fn test_verify_proof_three_leaves() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, node3) = test_append_one();
    let mut peaks: Array<felt252> = Default::default();
    peaks.append(node3);
    let (new_pos, new_root, new_arr) = stateless_mmr.append(4, peaks, last_pos, last_root);

    assert(new_pos == 4, 'new_pos should be 4');

    let mut test_peaks: Array<felt252> = Default::default();
    let node4 = PoseidonHasher::hash_double(4, 4);
    test_peaks.append(node3);
    test_peaks.append(node4);

    let result = stateless_mmr
        .verify_proof(4, 4, ArrayTrait::<felt252>::new(), test_peaks, new_pos, new_root)
        .unwrap();
    assert(result, 'verify_proof should return true');
}

#[test]
#[available_gas(200000000)]
fn test_verify_proof_four_leaves() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, last_peaks) = test_append_two();

    let (new_pos, new_root, new_arr) = stateless_mmr.append(5, last_peaks, last_pos, last_root);

    assert(new_pos == 7, 'new_pos should be 7');

    let (test_pos, test_root, test_peaks) = test_append_two();
    let mut proof: Array<felt252> = Default::default();
    proof.append(*test_peaks.at(1));
    proof.append(*test_peaks.at(0));

    let node5 = PoseidonHasher::hash_double(5, 5);
    let node6_1 = PoseidonHasher::hash_double(*test_peaks.at(1), node5);
    let node6 = PoseidonHasher::hash_double(6, node6_1);
    let node7_1 = PoseidonHasher::hash_double(*test_peaks.at(0), node6);
    let node7 = PoseidonHasher::hash_double(7, node7_1);
    let mut peaks: Array<felt252> = Default::default();
    peaks.append(node7);

    let result = stateless_mmr.verify_proof(5, 5, proof, peaks, new_pos, new_root).unwrap();
    assert(result, 'verify_proof should return true');
}

#[test]
#[available_gas(200000000)]
fn test_verify_proof_five_leaves() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, last_peaks) = test_append_three();
    let (new_pos, new_root, new_peaks) = stateless_mmr.append(8, last_peaks, last_pos, last_root);

    assert(new_pos == 8, 'new_pos should be 8');

    let (test_pos, test_root, mut test_peaks) = test_append_three();
    let node8 = PoseidonHasher::hash_double(8, 8);
    let proof: Array<felt252> = Default::default();
    test_peaks.append(node8);
    let result = stateless_mmr.verify_proof(8, 8, proof, new_peaks, new_pos, new_root).unwrap();
    assert(result, 'verify_proof should return true');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Result::unwrap failed.', ))]
fn test_verify_proof_invalid_index() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_peaks) = stateless_mmr.append(1, peaks, 0, 0);
    assert(new_pos == 1, 'new_pos should be 1');

    let mut test_peaks: Array<felt252> = Default::default();
    let node1 = PoseidonHasher::hash_double(1, 1);
    test_peaks.append(node1);
    let proofs: Array<felt252> = Default::default();
    let result = stateless_mmr.verify_proof(2, 2, proofs, test_peaks, new_pos, new_root).unwrap();
    assert(!result, 'verify_proof should false');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Result::unwrap failed.', ))]
fn test_verify_proof_invalid_peaks() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let mut peaks: Array<felt252> = Default::default();
    let (new_pos, new_root, new_peaks) = stateless_mmr.append(1, peaks, 0, 0);
    assert(new_pos == 1, 'new_pos should be 1');

    let mut test_peaks: Array<felt252> = Default::default();
    let invalid_node1 = PoseidonHasher::hash_double(1, 42);
    test_peaks.append(invalid_node1);
    let proofs: Array<felt252> = Default::default();
    let result = stateless_mmr.verify_proof(1, 1, proofs, test_peaks, new_pos, new_root).unwrap();
    assert(!result, 'verify_proof should false');
}

#[test]
#[available_gas(40000000)]
#[should_panic(expected: ('Result::unwrap failed.', ))]
fn test_verify_proof_invalid_proof() {
    let mut stateless_mmr = StatelessMmrTrait::new();
    let (last_pos, last_root, node1) = test_append_initial();
    let mut peaks: Array<felt252> = Default::default();
    peaks.append(node1);
    let (new_pos, new_root, mut new_arr) = stateless_mmr.append(2, peaks, last_pos, last_root);
    assert(new_pos == 3, 'new_pos should be 3');

    let node2 = PoseidonHasher::hash_double(2, 2);
    let node3_1 = PoseidonHasher::hash_double(node1, node2);
    let node3 = PoseidonHasher::hash_double(3, node3_1);
    new_arr.append(node3);
    let mut proof: Array<felt252> = Default::default();
    proof.append(node3);

    let result = stateless_mmr.verify_proof(2, 2, proof, new_arr, new_pos, new_root).unwrap();
    assert(!result, 'verify_proof should false');
}