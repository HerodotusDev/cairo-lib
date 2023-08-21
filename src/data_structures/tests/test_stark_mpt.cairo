use cairo_lib::data_structures::stark_mpt::{StarkMPT, StarkMPTTrait, StarkMPTNode, StarkMPTNodeTrait};
use cairo_lib::utils::types::bitarr::BitArr;
use array::ArrayTrait;

#[test]
#[available_gas(9999999999)]
fn test_hash_binary_node() {
    let binary = StarkMPTNode::Binary((9, 17));
    let expected_hash = 3448800753491155842114129004100047983009754105484160479464353352489980084140;

    assert(binary.hash() == expected_hash, 'Hash does not match');
}

#[test]
#[available_gas(9999999999)]
fn test_hash_edge_node() {
    let path = array![
        true, false, false, true, false, false, true, true,
        true, false, true, false, true, false, false, true
    ].span();
    let edge = StarkMPTNode::Edge((291872, path));
    let expected_hash = 800493211047958006469592108402751484180834315522274838721026790014228804959;

    assert(edge.hash() == expected_hash, 'Hash does not match');
}
