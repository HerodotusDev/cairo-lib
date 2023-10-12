use cairo_lib::hashing::keccak::keccak_cairo_words64;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode, rlp_decode_list_lazy};
use cairo_lib::utils::types::byte::{Byte, ByteTrait};
use cairo_lib::utils::bitwise::{right_shift, left_shift};
use cairo_lib::utils::types::words64::{Words64, Words64Trait, Words64TryIntoU256LE};
use cairo_lib::utils::math::pow;

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
#[derive(Drop, PartialEq)]
enum MPTNode {
    // @param 16 hashes of children
    // @param Value of the node
    Branch: (Span<Words64>, Words64),
    // @param hash of the next node
    LazyBranch: u256,
    // @param shared_nibbles
    // @param next_node
    // @param nibbles_skip Number of nibbles to skip in shared nibbles
    Extension: (Words64, u256, usize),
    // @param key_end
    // @param value of the node
    // @param nibbles_skip Number of nibbles to skip in the key end
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

        let proof_len = proof.len();

        loop {
            if proof_index == proof_len {
                break Result::Err('Proof reached end');
            }

            let node = *proof.at(proof_index);

            let hash = MPTTrait::hash_rlp_node(node);
            assert(hash == current_hash, 'Element not matching');

            // If it's not the last node and more than 9 words, it must be a branch node
            let decoded = if proof_index != proof_len - 1 && node.len() > 9 {
                let current_nibble = (key / key_pow2) & 0xf;
                // Unwrap impossible to fail, as we are masking with 0xf, meaning the result is always a nibble
                match MPTTrait::lazy_rlp_decode_branch_node(node, current_nibble.try_into().unwrap()) {
                    Result::Ok(decoded) => decoded,
                    Result::Err(e) => {
                        break Result::Err(e);
                    }
                }
            } else {
                match MPTTrait::decode_rlp_node(node) {
                    Result::Ok(decoded) => decoded,
                    Result::Err(e) => {
                        break Result::Err(e);
                    }
                }
            };
            match decoded {
                MPTNode::Branch((
                    nibbles, value
                )) => {
                    // If we reached the end of the key, return the value
                    if key_pow2 == 0 {
                        break Result::Ok(value);
                    }

                    let current_nibble = (key / key_pow2) & 0xf;
                    // Unwrap impossible to fail, as we are masking with 0xf, meaning the result is always a nibble
                    let current_hash_words = *nibbles.at(current_nibble.try_into().unwrap());
                    current_hash =
                        if current_hash_words.len() == 0 {
                            0
                        } else {
                            match current_hash_words.try_into() {
                                Option::Some(h) => h,
                                Option::None(_) => {
                                    break Result::Err('Invalid hash');
                                }
                            }
                        };
                    key_pow2 = key_pow2 / 16;
                },
                MPTNode::LazyBranch(next_node) => {
                    current_hash = next_node;
                    key_pow2 = key_pow2 / 16;
                },
                MPTNode::Extension((
                    shared_nibbles, next_node, nibbles_skip
                )) => {
                    let mut shared_nibbles_pow2 = pow(2, nibbles_skip.into() * 4);

                    let mut in_byte = false;
                    if nibbles_skip % 2 == 1 {
                        // Right shift 1 nibble
                        shared_nibbles_pow2 = shared_nibbles_pow2 / 16;
                        in_byte = true;
                    } else {
                        // Left shift 1 nibble
                        shared_nibbles_pow2 = shared_nibbles_pow2 * 16
                    }

                    let mut shared_nibbles_word_idx = nibbles_skip / 16;
                    let mut shared_nibbles_word = *shared_nibbles.at(shared_nibbles_word_idx);
                    let next_hash = loop {
                        if key_pow2 == 0 {
                            break Result::Err('Key reached end');
                        }

                        let current_nibble_shared_nibbles = (shared_nibbles_word
                            / shared_nibbles_pow2)
                            & 0xf;
                        let current_nibble_key = (key / key_pow2) & 0xf;
                        if current_nibble_shared_nibbles.into() != current_nibble_key {
                            break Result::Ok(next_node);
                        }

                        if shared_nibbles_pow2 == 0x100000000000000 {
                            shared_nibbles_pow2 = 16;
                            shared_nibbles_word_idx += 1;
                            shared_nibbles_word = *shared_nibbles.at(shared_nibbles_word_idx);
                        } else {
                            if in_byte {
                                shared_nibbles_pow2 = shared_nibbles_pow2 * 0x1000;
                            } else {
                                shared_nibbles_pow2 = shared_nibbles_pow2 / 0x10;
                            }
                        };

                        in_byte = !in_byte;
                        key_pow2 = key_pow2 / 16;
                    };

                    match next_hash {
                        Result::Ok(next_hash) => {
                            current_hash = next_hash;
                        },
                        Result::Err(e) => {
                            break Result::Err(e);
                        }
                    }
                },
                MPTNode::Leaf((
                    key_end, value, nibbles_skip
                )) => {
                    let mut key_end_pow2 = pow(2, nibbles_skip.into() * 4);

                    let mut in_byte = false;
                    if nibbles_skip % 2 == 1 {
                        // Right shift 1 nibble
                        key_end_pow2 = key_end_pow2 / 16;
                        in_byte = true;
                    } else {
                        // Left shift 1 nibble
                        key_end_pow2 = key_end_pow2 * 16
                    }

                    let mut key_end_word_idx = nibbles_skip / 16;
                    let mut key_end_word = *key_end.at(key_end_word_idx);
                    break loop {
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
                            let value = *l.at(16);
                            break Result::Ok(MPTNode::Branch((nibble_hashes.span(), value)));
                        }

                        nibble_hashes.append(*l.at(i));
                        i += 1;
                    }
                } else if len == 2 {
                    let first = *l.at(0);
                    // Unwrap impossible to fail, as we are making with 0xff, meaning the result always fits in a byte
                    let prefix_byte: Byte = (*first.at(0) & 0xff).try_into().unwrap();
                    let (prefix, _) = prefix_byte.extract_nibbles();

                    if prefix == 0 {
                        match (*l.at(1)).try_into() {
                            Option::Some(n) => Result::Ok(MPTNode::Extension((first, n, 2))),
                            Option::None(_) => Result::Err('Invalid next node')
                        }
                    } else if prefix == 1 {
                        match (*l.at(1)).try_into() {
                            Option::Some(n) => Result::Ok(MPTNode::Extension((first, n, 1))),
                            Option::None(_) => Result::Err('Invalid next node')
                        }
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

    
    fn lazy_rlp_decode_branch_node(rlp: Words64, current_nibble: u8) -> Result<MPTNode, felt252> {
        let hash_words = rlp_decode_list_lazy(rlp, array![current_nibble.into()].span())?;
        match (*hash_words.at(0)).try_into() {
            Option::Some(h) => Result::Ok(MPTNode::LazyBranch(h)),
            Option::None(_) => Result::Err('Invalid hash')
        }
    }

    // @notice keccak256 hashes an RLP encoded node
    // @param rlp RLP encoded node
    // @return keccak256 hash of the node
    fn hash_rlp_node(rlp: Words64) -> u256 {
        keccak_cairo_words64(rlp)
    }
}
