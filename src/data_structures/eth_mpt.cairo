use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakTrait;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode};
use cairo_lib::utils::types::bytes::{Bytes, BytesTryIntoU256, BytesPartialEq};
use cairo_lib::utils::types::byte::{Byte, ByteTrait};
use traits::{TryInto, Into};
use option::OptionTrait;
use cairo_lib::utils::bitwise::{right_shift, left_shift};
use keccak::u128_split;
use cairo_lib::utils::types::words64::{
    Words64, Words64Trait, Words64TryIntoU256LE, Words64PartialEq, bytes_used, left_shift_u64
};
use cairo_lib::utils::math::pow;
use debug::PrintTrait;


// @notice Ethereum Merkle Patricia Trie struct
#[derive(Drop)]
struct MPT {
    root: u256
}

impl MPTDefault of Default<MPT> {
    // @return MPT with root 0
    fn default() -> MPT {
        MPTTrait::new(0)
    }
}

// @notice Represents a node in the MPT
#[derive(Drop)]
enum MPTNode {
    // @param 16 hashes of children
    // @param Value of the node
    Branch: (Span<u256>, Words64),
    // @param shared_nibbles
    // @param next node
    // @param nibbles_skip Number of nibbles to skip in shared nibbles
    Extension: (Words64, u256, usize),
    // @param key_end
    // @param value of the node
    // param nibbles_skip Number of nibbles to skip in the key end
    Leaf: (Words64, Words64, usize)
}

#[generate_trait]
impl MPTImpl of MPTTrait {
    // @notice Create a new MPT with a root
    // @param root Root of the MPT
    // @return MPT with the given root
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    // @notice Verify that a key exists in the MPT
    // @param key Key to verify
    // @param key_len Length of they key in nibbles
    // @param proof Merkle proof, collection of rlp encoded nodes
    // @return Result with the value associated with the key if it exists
    fn verify(
        self: @MPT, key: u256, key_len: usize, proof: Span<Words64>
    ) -> Result<Words64, felt252> {
        let mut current_hash = *self.root;
        let mut proof_index: usize = 0;
        let mut key_pow2: u256 = pow(2, (key_len.into() - 1) * 4);

        loop {
            if proof_index == proof.len() {
                break Result::Err('Proof reached end');
            }

            let node = *proof.at(proof_index);

            let hash = MPTTrait::hash_rlp_node(node);
            assert(hash == current_hash, 'Element not matching');

            let decoded = MPTTrait::decode_rlp_node(node)?;
            match decoded {
                MPTNode::Branch((
                    nibbles, value
                )) => {
                    if key_pow2 == 1 {
                        break Result::Ok(value);
                    }

                    let current_nibble = (key / key_pow2) & 0xf;
                    current_hash = *nibbles.at(current_nibble.try_into().unwrap());
                    key_pow2 = key_pow2 / 16;
                },
                MPTNode::Extension((
                    shared_nibbles, next_node, nibbles_skip
                )) => {
                    break Result::Err('Not implemented');
                },
                MPTNode::Leaf((
                    key_end, value, nibbles_skip
                )) => {
                    let mut key_end_pow2 = pow(2, nibbles_skip.into() * 4);

                    let mut in_byte = false;
                    if nibbles_skip % 2 == 1 {
                        key_end_pow2 = key_end_pow2 / 16;
                        in_byte = true;
                    } else {
                        key_end_pow2 = key_end_pow2 * 16
                    }

                    let mut key_end_word_idx = nibbles_skip / 16;
                    let mut key_end_word = *key_end.at(key_end_word_idx);
                    let v = loop {
                        if key_pow2 == 0 {
                            break Result::Ok(value);
                        }

                        let current_nibble_key_end = (key_end_word / key_end_pow2) & 0xf;
                        let current_nibble_key = (key / key_pow2) & 0xf;
                        if current_nibble_key_end.into() != current_nibble_key {
                            break Result::Err('Key not matching');
                        }

                        if key_end_pow2 == 0x100000000000000 {
                            key_end_pow2 = 16;
                            key_end_word_idx += 1;
                            key_end_word = *key_end.at(key_end_word_idx);
                        } else {
                            if in_byte {
                                key_end_pow2 = key_end_pow2 * 0x1000;
                            } else {
                                key_end_pow2 = key_end_pow2 / 0x10;
                            }
                        };

                        in_byte = !in_byte;
                        key_pow2 = key_pow2 / 16;
                    };
                    break v;
                }
            };

            proof_index += 1;
        }
    }

    // @notice Decodes an RLP encoded node
    // @param rlp RLP encoded node
    // @return Result with the decoded node
    fn decode_rlp_node(rlp: Words64) -> Result<MPTNode, felt252> {
        let (item, _) = rlp_decode(rlp)?;
        match item {
            RLPItem::Bytes(_) => Result::Err('Invalid RLP for node'),
            RLPItem::List(l) => {
                let len = l.len();
                if len == 17 {
                    let mut nibble_hashes = ArrayTrait::new();
                    let mut i: usize = 0;
                    loop {
                        if i == 16 {
                            break ();
                        }

                        let current = *l.at(i);
                        let hash = if current.len() == 0 {
                            0
                        } else {
                            current.try_into().unwrap()
                        };
                        nibble_hashes.append(hash);
                        i += 1;
                    };
                    let value = *l.at(16);

                    Result::Ok(MPTNode::Branch((nibble_hashes.span(), value)))
                } else if len == 2 {
                    let first = *l.at(0);
                    let prefix_byte: Byte = (*first.at(0) & 0xff).try_into().unwrap();
                    let (prefix, _) = prefix_byte.extract_nibbles();

                    if prefix == 0 {
                        Result::Ok(MPTNode::Extension((first, (*l.at(1)).try_into().unwrap(), 2)))
                    } else if prefix == 1 {
                        Result::Ok(MPTNode::Extension((first, (*l.at(1)).try_into().unwrap(), 1)))
                    } else if prefix == 2 {
                        Result::Ok(MPTNode::Leaf((first, *l.at(1), 2)))
                    } else if prefix == 3 {
                        Result::Ok(MPTNode::Leaf((first, *l.at(1), 1)))
                    } else {
                        Result::Err('Invalid RLP prefix')
                    }
                } else {
                    Result::Err('Invalid RLP list len')
                }
            }
        }
    }

    // @notice keccak256 hashes an RLP encoded node
    // @param rlp RLP encoded node
    // @return keccak256 hash of the node
    fn hash_rlp_node(rlp: Words64) -> u256 {
        KeccakTrait::keccak_cairo_word64(rlp)
    }
}

impl MPTNodePartialEq of PartialEq<MPTNode> {
    fn eq(lhs: @MPTNode, rhs: @MPTNode) -> bool {
        match lhs {
            MPTNode::Branch((
                lhs_nibbles, lhs_value
            )) => {
                match rhs {
                    MPTNode::Branch((
                        rhs_nibbles, rhs_value
                    )) => {
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
            MPTNode::Extension((
                lhs_shared_nibbles, lhs_next_node, lhs_nibbles_skip
            )) => {
                match rhs {
                    MPTNode::Branch(_) => false,
                    MPTNode::Extension((
                        rhs_shared_nibbles, rhs_next_node, rhs_nibbles_skip
                    )) => {
                        lhs_shared_nibbles == rhs_shared_nibbles
                            && lhs_next_node == rhs_next_node
                            && lhs_nibbles_skip == rhs_nibbles_skip
                    },
                    MPTNode::Leaf(_) => false
                }
            },
            MPTNode::Leaf((
                lhs_key_end, lhs_value, lhs_nibbles_skip
            )) => {
                match rhs {
                    MPTNode::Branch(_) => false,
                    MPTNode::Extension(_) => false,
                    MPTNode::Leaf((
                        rhs_key_end, rhs_value, rhs_nibbles_skip
                    )) => {
                        lhs_key_end == rhs_key_end
                            && lhs_value == rhs_value
                            && lhs_nibbles_skip == rhs_nibbles_skip
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
