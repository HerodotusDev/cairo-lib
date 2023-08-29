use array::{ArrayTrait, SpanTrait};
use cairo_lib::hashing::keccak::KeccakTrait;
use cairo_lib::encoding::rlp_word64::{RLPItemWord64, rlp_decode_word64};
use cairo_lib::utils::types::bytes::{Bytes, BytesTryIntoU256, BytesPartialEq};
use cairo_lib::utils::types::byte::ByteTrait;
use traits::{TryInto, Into};
use option::OptionTrait;
use cairo_lib::utils::bitwise::right_shift;
use keccak::u128_split;
use cairo_lib::utils::types::words64::{Words64, Words64Trait};


// @notice Ethereum Merkle Patricia Trie struct
#[derive(Drop)]
struct MPTWords64 {
    root: u256
}

impl MPTWords64Default of Default<MPTWords64> {
    // @return MPTWords64 with root 0
    fn default() -> MPTWords64 {
        MPTWords64Trait::new(0)
    }
}

// @notice Represents a node in the MPTWords64
#[derive(Drop)]
enum MPTWords64Node {
    // @param 16 hashes of children
    // @param Value of the node
    Branch: (Span<u256>, Bytes),
    // @param shared nibbles
    // @param next node
    Extension: (Bytes, u256),
    // @param key end
    // @param value of the node
    Leaf: (Bytes, Bytes)
}

#[generate_trait]
impl MPTWords64Impl of MPTWords64Trait {
    // @notice Create a new MPTWords64 with a root
    // @param root Root of the MPTWords64
    // @return MPTWords64 with the given root
    fn new(root: u256) -> MPTWords64 {
        MPTWords64 { root }
    }

    // @notice Verify that a key exists in the MPTWords64
    // @param key Key to verify, must be a nibble collection (Ex: array![0xf, 0x2, 0xa].span())
    // @param proof Merkle proof, collection of rlp encoded nodes
    // @return Result with the value associated with the key if it exists
    //fn verify(self: @MPTWords64, key: Bytes, proof: Span<Bytes>) -> Result<Bytes, felt252> {
        //let mut current_hash = 0;
        //let mut proof_index: usize = 0;
        //let mut key_index: usize = 0;

        //loop {
            //if proof_index >= proof.len() {
                //break Result::Err('Proof reached end');
            //}

            //let node = *proof.at(proof_index);
            //proof_index += 1;

            //let hash = MPTWords64Trait::hash_rlp_node(node);
            //if key_index == 0 {
                //assert(hash == *self.root, 'Root not matching');
            //} else {
                //// TODO handle edge case where RLP is less than 32 bytes
                //assert(hash == current_hash, 'Element not matching');
            //}

            //let decoded = MPTWords64Trait::decode_rlp_node(node)?;
            //match decoded {
                //MPTWords64Node::Branch((
                    //nibbles, value
                //)) => {
                    //if key_index >= key.len() {
                        //break Result::Ok(value);
                    //} else {
                        //current_hash = *nibbles.at((*key.at(key_index)).into());
                    //}
                    //key_index += 1;
                //},
                //MPTWords64Node::Extension((
                    //shared_nibbles, next_node
                //)) => {
                    //let expected_shared_nibbles = key.slice(key_index, shared_nibbles.len());
                    //if expected_shared_nibbles == shared_nibbles {
                        //current_hash = next_node;
                    //} else {
                        //break Result::Err('Shared nibbles not matching');
                    //}
                    //key_index += shared_nibbles.len();
                //},
                //MPTWords64Node::Leaf((
                    //key_end, value
                //)) => {
                    //let expected_end = key.slice(key_index, key.len() - key_index);
                    //if expected_end == key_end {
                        //break Result::Ok(value);
                    //} else {
                        //break Result::Err('Key not matching in leaf node');
                    //}
                //}
            //};
        //}
    //}

    // @notice Decodes an RLP encoded node
    // @param rlp RLP encoded node
    // @return Result with the decoded node
    fn decode_rlp_node(rlp: Words64) -> Result<MPTWords64Node, felt252> {
        let (item, _) = rlp_decode_word64(rlp)?;
        match item {
            RLPItemWord64::Bytes(_) => Result::Err('Invalid RLP for node'),
            RLPItemWord64::List(l) => {
                let len = l.len();
                if len == 17 {
                    //let nibble_hashes_bytes = l.slice(0, 16);
                    //let mut nibble_hashes = ArrayTrait::new();
                    //let mut i: usize = 0;
                    //loop {
                        //if i >= nibble_hashes_bytes.len() {
                            //break ();
                        //}

                        //let hash = (*nibble_hashes_bytes.at(i)).try_into().unwrap();
                        //nibble_hashes.append(hash);
                        //i += 1;
                    //};
                    //let value = *l.at(16);

                    //Result::Ok(MPTWords64Node::Branch((nibble_hashes.span(), value)))
                    Result::Err('Not implemented')
                } else if len == 2 {
                    Result::Err('Not implemented')
                    //let (prefix, nibble) = (*(*l.at(0)).at(0)).extract_nibbles();

                    //if prefix == 0 {
                        //let mut shared_nibbles = *l.at(0);
                        //let mut i: usize = 1;
                        //let mut shared_nibbles_nibbles = ArrayTrait::new();
                        //shared_nibbles_nibbles.append(nibble);
                        //loop {
                            //if i >= shared_nibbles.len() {
                                //break ();
                            //}

                            //let (high, low) = (*shared_nibbles.at(i)).extract_nibbles();
                            //shared_nibbles_nibbles.append(high);
                            //shared_nibbles_nibbles.append(low);

                            //i += 1;
                        //};

                        //let next_node = (*l.at(1)).try_into().unwrap();
                        //Result::Ok(MPTWords64Node::Extension((shared_nibbles_nibbles.span(), next_node)))
                    //} else if prefix == 1 {
                        //let mut shared_nibbles = *l.at(0);
                        //let mut i: usize = 1;
                        //let mut shared_nibbles_nibbles = ArrayTrait::new();
                        //loop {
                            //if i >= shared_nibbles.len() {
                                //break ();
                            //}

                            //let (high, low) = (*shared_nibbles.at(i)).extract_nibbles();
                            //shared_nibbles_nibbles.append(high);
                            //shared_nibbles_nibbles.append(low);

                            //i += 1;
                        //};

                        //let next_node = (*l.at(1)).try_into().unwrap();
                        //Result::Ok(MPTWords64Node::Extension((shared_nibbles_nibbles.span(), next_node)))
                    //} else if prefix == 2 {
                        //let key_end = *l.at(0);
                        //let mut i: usize = 1;
                        //let mut key_end_nibbles = ArrayTrait::new();
                        //loop {
                            //if i >= key_end.len() {
                                //break ();
                            //}

                            //let (high, low) = (*key_end.at(i)).extract_nibbles();
                            //key_end_nibbles.append(high);
                            //key_end_nibbles.append(low);

                            //i += 1;
                        //};

                        //let value = *l.at(1);
                        //Result::Ok(MPTWords64Node::Leaf((key_end_nibbles.span(), value)))
                    //} else if prefix == 3 {
                        //let key_end = *l.at(0);
                        //let mut i: usize = 1;
                        //let mut key_end_nibbles = ArrayTrait::new();
                        //key_end_nibbles.append(nibble);
                        //loop {
                            //if i >= key_end.len() {
                                //break ();
                            //}
                            //let (high, low) = (*key_end.at(i)).extract_nibbles();
                            //key_end_nibbles.append(high);
                            //key_end_nibbles.append(low);

                            //i += 1;
                        //};

                        //let value = *l.at(1);
                        //Result::Ok(MPTWords64Node::Leaf((key_end_nibbles.span(), value)))
                    //} else {
                        //Result::Err('Invalid RLP prefix')
                    //}
                } else {
                    Result::Err('Invalid RLP list len')
                }
            }
        }
    }

    // @notice keccak256 hashes an RLP encoded node
    // @param rlp RLP encoded node
    // @return keccak256 hash of the node
    fn hash_rlp_node(rlp: Bytes) -> u256 {
        let keccak_res = KeccakTrait::keccak_cairo(rlp);
        let high = integer::u128_byte_reverse(keccak_res.high);
        let low = integer::u128_byte_reverse(keccak_res.low);
        u256 { low: high, high: low }
    }
}

impl MPTWords64NodePartialEq of PartialEq<MPTWords64Node> {
    fn eq(lhs: @MPTWords64Node, rhs: @MPTWords64Node) -> bool {
        match lhs {
            MPTWords64Node::Branch((
                lhs_nibbles, lhs_value
            )) => {
                match rhs {
                    MPTWords64Node::Branch((
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
                    MPTWords64Node::Extension(_) => false,
                    MPTWords64Node::Leaf(_) => false
                }
            },
            MPTWords64Node::Extension((
                lhs_shared_nibbles, lhs_next_node
            )) => {
                match rhs {
                    MPTWords64Node::Branch(_) => false,
                    MPTWords64Node::Extension((
                        rhs_shared_nibbles, rhs_next_node
                    )) => {
                        lhs_shared_nibbles == rhs_shared_nibbles && lhs_next_node == rhs_next_node
                    },
                    MPTWords64Node::Leaf(_) => false
                }
            },
            MPTWords64Node::Leaf((
                lhs_key_end, lhs_value
            )) => {
                match rhs {
                    MPTWords64Node::Branch(_) => false,
                    MPTWords64Node::Extension(_) => false,
                    MPTWords64Node::Leaf((
                        rhs_key_end, rhs_value
                    )) => {
                        lhs_key_end == rhs_key_end && lhs_value == rhs_value
                    }
                }
            }
        }
    }

    fn ne(lhs: @MPTWords64Node, rhs: @MPTWords64Node) -> bool {
        // TODO optimize
        !(lhs == rhs)
    }
}
