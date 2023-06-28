use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakHasherSpanU8;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode};
use cairo_lib::utils::types::{Bytes, BytesTryIntoU256, BytesPartialEq};
use traits::{TryInto, Into};
use option::OptionTrait;
use cairo_lib::utils::bitwise::right_shift;

#[derive(Drop)]
struct MPT {
    root: u256
}

trait MPTTrait {
    fn new(root: u256) -> MPT;
    fn verify(self: @MPT, key: Bytes, proof: Span<Bytes>) -> Result<u256, felt252>;
    fn decode_rlp_node(rlp: Bytes) -> Result<MPTNode, felt252>;
}

impl MPTDefault of Default<MPT> {
    fn default() -> MPT {
        MPTTrait::new(0)
    }
}

#[derive(Drop)]
enum MPTNode {
    // hashes of correspondible child with nibble, value
    Branch: (Span<Bytes>, u256),
    // shared nibbles, next node
    Extension: (Bytes, u256),
    // key end, value
    Leaf: (Bytes, u256)
}

impl MPTImpl of MPTTrait {
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    fn verify(self: @MPT, key: Bytes, proof: Span<Bytes>) -> Result<u256, felt252> {
        let mut current_hash = 0;
        let mut proof_index: usize = 0;
        let mut key_index: usize = 0;

        loop {
            if proof_index >= proof.len() {
                break Result::Err('Proof reached end');
            }

            let node = *proof.at(proof_index);
            proof_index += 1;

            let hash = KeccakHasherSpanU8::hash_single(node);
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
                        current_hash = (*nibbles.at((*key.at(key_index)).into())).try_into().unwrap();
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
                    let nibble_hashes = l.slice(0, 16);
                    // TODO error handling (should never fail if RLP is properly formated)
                    let value = (*l.at(16)).try_into().unwrap();
                    
                    Result::Ok(MPTNode::Branch((nibble_hashes, value)))
                } else if len == 2 {
                    let (prefix, nibble) = extract_nibbles(*(*l.at(0)).at(0));

                    if prefix == 0 {
                        let mut shared_nibbles = *l.at(0);
                        shared_nibbles.pop_front();

                        // TODO error handling (should never fail if RLP is properly formated)
                        let next_node = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Extension((shared_nibbles, next_node)))
                    } else if prefix == 1 {
                        let mut shared_nibbles = *l.at(0);
                        shared_nibbles.pop_front();

                         // TODO optimize logic without creating new array
                        let mut i: usize = 0;
                        let mut arr = ArrayTrait::new();
                        arr.append(nibble);
                        loop {
                            if i >= shared_nibbles.len() {
                                break ();
                            }
                            arr.append(*shared_nibbles.at(i));
                            i += 1;
                        };

                        // TODO error handling (should never fail if RLP is properly formated)
                        let next_node = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Extension((arr.span(), next_node)))
                    } else if prefix == 2 {
                        let mut key_end = *l.at(0);
                        key_end.pop_front();

                        // TODO error handling (should never fail if RLP is properly formated)
                        let value = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Leaf((key_end, value)))
                    } else if prefix == 3 {
                        let mut key_end = *l.at(0);
                        key_end.pop_front();

                         // TODO optimize logic without creating new array
                        let mut i: usize = 0;
                        let mut arr = ArrayTrait::new();
                        arr.append(nibble);
                        loop {
                            if i >= key_end.len() {
                                break ();
                            }
                            arr.append(*key_end.at(i));
                            i += 1;
                        };

                        // TODO error handling (should never fail if RLP is properly formated)
                        let value = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Leaf((arr.span(), value)))
                    } else {
                        Result::Err('Invalid RLP prefix')
                    }
                } else {
                    Result::Err('Invalid RLP list len')
                }
            }
        }
    }
}

fn extract_nibbles(byte: u8) -> (u8, u8) {
    // TODO fix all hte conversions. Bitwise AND only supported for u128 and u256 :(
    // (next compiler version already supports)
    let masked = byte.into() & 0xf0_u128;
    let high = right_shift(masked, 4);
    let low = byte.into() & 0x0f_u128;

    (high.try_into().unwrap(), low.try_into().unwrap())
}
