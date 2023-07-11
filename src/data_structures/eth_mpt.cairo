use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakTrait;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode};
use cairo_lib::utils::types::bytes::{Bytes, BytesTryIntoU256, BytesPartialEq};
use cairo_lib::utils::types::byte::ByteTrait;
use traits::{TryInto, Into};
use option::OptionTrait;
use cairo_lib::utils::bitwise::right_shift;
use keccak::u128_split;

// TODO create nibble type

#[derive(Drop)]
struct MPT {
    root: u256
}

impl MPTDefault of Default<MPT> {
    fn default() -> MPT {
        MPTTrait::new(0)
    }
}

#[derive(Drop)]
enum MPTNode {
    // hashes of correspondible child with nibble, value
    Branch: (Span<u256>, Bytes),
    // shared nibbles, next node
    Extension: (Bytes, u256),
    // key end, value
    Leaf: (Bytes, Bytes)
}

#[generate_trait]
impl MPTImpl of MPTTrait {
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    // key is a nibble array
    fn verify(self: @MPT, key: Bytes, proof: Span<Bytes>) -> Result<Bytes, felt252> {
        let mut current_hash = 0;
        let mut proof_index: usize = 0;
        let mut key_index: usize = 0;

        loop {
            if proof_index >= proof.len() {
                break Result::Err('Proof reached end');
            }

            let node = *proof.at(proof_index);
            proof_index += 1;

            let hash = MPTTrait::hash_rlp_node(node);
            if key_index == 0 {
                assert(hash == *self.root, 'Root not matching');
            } else {
                // TODO handle edge case where RLP is less than 32 bytes
                assert(hash == current_hash, 'Element not matching');
            }

            let decoded = MPTTrait::decode_rlp_node(node)?;
            match decoded {
                MPTNode::Branch((nibbles, value)) => {
                    if key_index >= key.len() {
                        break Result::Ok(value);
                    } else {
                        // TODO error handling
                        current_hash = *nibbles.at((*key.at(key_index)).into());
                    }
                    key_index += 1;
                },
                MPTNode::Extension((shared_nibbles, next_node)) => {
                    let expected_shared_nibbles = key.slice(key_index, shared_nibbles.len());
                    if expected_shared_nibbles == shared_nibbles {
                        current_hash = next_node;
                    } else {
                        break Result::Err('Shared nibbles not matching');
                    }
                    key_index += shared_nibbles.len();
                },
                MPTNode::Leaf((key_end, value)) => {
                    let expected_end = key.slice(key_index, key.len() - key_index);
                    if expected_end == key_end {
                        break Result::Ok(value);
                    } else {
                        break Result::Err('Key not matching in leaf node');
                    }
                }
            };
        }
    }

    fn decode_rlp_node(rlp: Bytes) -> Result<MPTNode, felt252> {
        let (item, _) = rlp_decode(rlp)?;
        match item {
            RLPItem::Bytes(_) => Result::Err('Invalid RLP for node'),
            RLPItem::List(l) => {
                let len = l.len();
                if len == 17 {
                    let nibble_hashes_bytes = l.slice(0, 16);
                    let mut nibble_hashes = ArrayTrait::new();
                    let mut i: usize = 0;
                    loop {
                        if i >= nibble_hashes_bytes.len() {
                            break ();
                        }

                        // TODO error handling
                        let hash = (*nibble_hashes_bytes.at(i)).try_into().unwrap();
                        nibble_hashes.append(hash);
                        i += 1;
                    };
                    let value = *l.at(16);
                    
                    Result::Ok(MPTNode::Branch((nibble_hashes.span(), value)))
                } else if len == 2 {
                    let (prefix, nibble) = (*(*l.at(0)).at(0)).extract_nibbles();

                    if prefix == 0 {
                        let mut shared_nibbles = *l.at(0);
                        let mut i: usize = 1;
                        let mut shared_nibbles_nibbles = ArrayTrait::new();
                        shared_nibbles_nibbles.append(nibble);
                        loop {
                            if i >= shared_nibbles.len() {
                                break ();
                            }

                            let (high, low) = (*shared_nibbles.at(i)).extract_nibbles();
                            shared_nibbles_nibbles.append(high);
                            shared_nibbles_nibbles.append(low);

                            i += 1;
                        };

                        // TODO error handling (should never fail if RLP is properly formated)
                        let next_node = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Extension((shared_nibbles_nibbles.span(), next_node)))
                    } else if prefix == 1 {
                        let mut shared_nibbles = *l.at(0);
                        let mut i: usize = 1;
                        let mut shared_nibbles_nibbles = ArrayTrait::new();
                        loop {
                            if i >= shared_nibbles.len() {
                                break ();
                            }

                            let (high, low) = (*shared_nibbles.at(i)).extract_nibbles();
                            shared_nibbles_nibbles.append(high);
                            shared_nibbles_nibbles.append(low);

                            i += 1;
                        };

                        // TODO error handling (should never fail if RLP is properly formated)
                        let next_node = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Extension((shared_nibbles_nibbles.span(), next_node)))
                    } else if prefix == 2 {
                        let key_end = *l.at(0);
                        let mut i: usize = 1;
                        let mut key_end_nibbles = ArrayTrait::new();
                        loop {
                            if i >= key_end.len() {
                                break ();
                            }

                            let (high, low) = (*key_end.at(i)).extract_nibbles();
                            key_end_nibbles.append(high);
                            key_end_nibbles.append(low);

                            i += 1;
                        };

                        let value = *l.at(1);
                        Result::Ok(MPTNode::Leaf((key_end_nibbles.span(), value)))
                    } else if prefix == 3 {
                        let key_end = *l.at(0);
                        let mut i: usize = 1;
                        let mut key_end_nibbles = ArrayTrait::new();
                        key_end_nibbles.append(nibble);
                        loop {
                            if i >= key_end.len() {
                                break ();
                            }
                            let (high, low) = (*key_end.at(i)).extract_nibbles();
                            key_end_nibbles.append(high);
                            key_end_nibbles.append(low);

                            i += 1;
                        };

                        let value = *l.at(1);
                        Result::Ok(MPTNode::Leaf((key_end_nibbles.span(), value)))
                    } else {
                        Result::Err('Invalid RLP prefix')
                    }
                } else {
                    Result::Err('Invalid RLP list len')
                }
            }
        }
    }

    fn hash_rlp_node(rlp: Bytes) -> u256 {
        let keccak_res = KeccakTrait::keccak_cairo(rlp);
        let high = integer::u128_byte_reverse(keccak_res.high);
        let low = integer::u128_byte_reverse(keccak_res.low);
        u256 { low: high, high: low }
    }
}

impl MPTNodePartialEq of PartialEq<MPTNode> {
    fn eq(lhs: @MPTNode, rhs: @MPTNode) -> bool {
        match lhs {
            MPTNode::Branch((lhs_nibbles, lhs_value)) => {
                match rhs {
                    MPTNode::Branch((rhs_nibbles, rhs_value)) => {
                        if (*lhs_nibbles).len() != (*rhs_nibbles).len() {
                            return false;
                        }
                        let mut i: usize = 0;
                        loop {
                            if i >= (*lhs_nibbles).len() {
                                break lhs_value == rhs_value;
                            }
                            if (*lhs_nibbles).at(i) != (*rhs_nibbles).at(i) {
                                break false;
                            }
                            i += 1;
                        }
                    },
                    MPTNode::Extension(_) => false,
                    MPTNode::Leaf(_) => false
                }
            },
            MPTNode::Extension((lhs_shared_nibbles, lhs_next_node)) => {
                match rhs {
                    MPTNode::Branch(_) => false,
                    MPTNode::Extension((rhs_shared_nibbles, rhs_next_node)) => {
                        lhs_shared_nibbles == rhs_shared_nibbles && lhs_next_node == rhs_next_node
                    },
                    MPTNode::Leaf(_) => false
                }
            },
            MPTNode::Leaf((lhs_key_end, lhs_value)) => {
                match rhs {
                    MPTNode::Branch(_) => false,
                    MPTNode::Extension(_) => false,
                    MPTNode::Leaf((rhs_key_end, rhs_value)) => {
                        lhs_key_end == rhs_key_end && lhs_value == rhs_value
                    }
                }
            }
        }
    }

    fn ne(lhs: @MPTNode, rhs: @MPTNode) -> bool {
        // TODO optimize
        !(lhs == rhs)
    }
}
