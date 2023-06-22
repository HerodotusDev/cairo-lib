use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakHasherSpanU8;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode};
use traits::Into;

#[derive(Drop)]
struct MPT {
    root: u256
}

trait MPTTrait {
    fn new(root: u256) -> MPT;
    fn verify(self: @MPT, proof: Span<Span<u8>>) -> Result<u256, felt252>;
    fn decode_rlp_node(rlp: Span<u8>) -> Result<MPTNode, felt252>;
}

impl MPTDefault of Default<MPT> {
    fn default() -> MPT {
        MPTTrait::new(0)
    }
}

#[derive(Drop)]
enum MPTNode {
    // hashes of correspondible child with nibble, value
    Branch: (Array<u256>, u256),
    // even, shared nibbles, next node
    Extension: (bool, u256, u256),
    // even, key end, value
    Leaf: (bool, u256, u256)
}

impl MPTImpl of MPTTrait {
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    fn verify(self: @MPT, proof: Span<Span<u8>>) -> Result<u256, felt252> {
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

    fn decode_rlp_node(rlp: Span<u8>) -> Result<MPTNode, felt252> {
        let items = rlp_decode(rlp)?;
        if items.len() != 1 {
            return Result::Err('Multiple items in RLP for node');
        }

        let item = items.at(0);
        match item {
            RLPItem::Bytes(_) => Result::Err('Invalid RLP for node'),
            RLPItem::List(l) => {
                let len = l.len();
                if len == 17 {
                    let mut nibble_hashes = l.span();
                    nibble_hashes.pop_front();
                    // TODO remove this line and convert bytes array to number
                    let nibble_hashes = ArrayTrait::new();

                    // TODO convert bytes array to number (l[16])
                    let value = 0;
                    Result::Ok(MPTNode::Branch((nibble_hashes, value)))
                } else if len == 2 {
                    let prefix = *l.at(0).at(0);
                    let nibble = *l.at(0).at(1);

                    if prefix == 0 {
                        let mut shared_nibbles = l.at(0).span();
                        shared_nibbles.pop_back();

                        // TODO convert from shared_nibbles_array
                        let shared_nibbles = 0;
                        // TODO convert from bytes array (l[1])
                        let next_node = 0;
                        Result::Ok(MPTNode::Extension((true, shared_nibbles, next_node)))
                    } else if prefix == 1 {
                        let mut shared_nibbles = l.at(0).span();
                        shared_nibbles.pop_back();

                        // TODO convert from shared_nibbles_array
                        let shared_nibbles = nibble.into() + 0;
                        // TODO convert from bytes array (l[1])
                        let next_node = 0;
                        Result::Ok(MPTNode::Extension((false, shared_nibbles, next_node)))
                    } else if prefix == 2 {
                        let mut key_end = l.at(0).span();
                        key_end.pop_back();

                        // TODO convert from key_end array
                        let key_end = 0;
                        // TODO convert bytes array to number (l[1])
                        let value = 0;
                        Result::Ok(MPTNode::Leaf((true, key_end, value)))
                    } else if prefix == 3 {
                        let mut key_end = l.at(0).span();
                        key_end.pop_back();

                        // TODO convert from key_end array
                        let key_end = nibble.into() + 0;
                        // TODO convert bytes array to number (l[1])
                        let value = 0;
                        Result::Ok(MPTNode::Leaf((false, key_end, value)))
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
