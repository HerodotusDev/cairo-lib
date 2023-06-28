use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakHasherSpanU8;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode};
use cairo_lib::utils::types::{Bytes, BytesTryIntoU256};
use traits::{TryInto, Into};
use option::OptionTrait;
use cairo_lib::utils::bitwise::right_shift;

#[derive(Drop)]
struct MPT {
    root: u256
}

trait MPTTrait {
    fn new(root: u256) -> MPT;
    fn verify(self: @MPT, proof: Span<Bytes>) -> Result<u256, felt252>;
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
    // even, shared nibbles, next node
    Extension: (bool, Bytes, u256),
    // even, key end, value
    Leaf: (bool, Bytes, u256)
}

impl MPTImpl of MPTTrait {
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    fn verify(self: @MPT, proof: Span<Bytes>) -> Result<u256, felt252> {
        let mut i: usize = 0;
        let mut current_element = ArrayTrait::new().span();
        let mut current_element_hash = 0;
        let mut next_element_hash = 0;
        loop {
            if i >= proof.len() {
                break Result::Err('Proof is over');
            }

            current_element = *proof[i];
            current_element_hash = KeccakHasherSpanU8::hash_single(current_element);

            if i == 0 {
                assert(current_element_hash == *self.root, 'Root not matching');
            } else {
                // TODO handle case where RLP < 32 bytes and not hashed
                assert(current_element_hash == next_element_hash, 'Element not matching');
            }

            let node = MPTTrait::decode_rlp_node(current_element)?;

            match node {
                MPTNode::Branch((nibbles, value)) => {
                    if i == proof.len() - 1 {
                        break Result::Ok(value);
                    } else {
                        // TODO
                    }
                },
                MPTNode::Extension((even, shared_nibbles, next_node)) => {
                    // TODO
                },
                MPTNode::Leaf((even, key_end, value)) => {

                }
            }

            break Result::Err('Match failed');
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
                        Result::Ok(MPTNode::Extension((true, shared_nibbles, next_node)))
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
                        Result::Ok(MPTNode::Extension((false, arr.span(), next_node)))
                    } else if prefix == 2 {
                        let mut key_end = *l.at(0);
                        key_end.pop_front();

                        // TODO error handling (should never fail if RLP is properly formated)
                        let value = (*l.at(1)).try_into().unwrap();
                        Result::Ok(MPTNode::Leaf((true, key_end, value)))
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
                        Result::Ok(MPTNode::Leaf((true, arr.span(), value)))
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
