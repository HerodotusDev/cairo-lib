use array::SpanTrait;
use cairo_lib::hashing::keccak::KeccakHasher;

#[derive(Drop)]
struct MPT {
    root: u256
}

trait MPTTrait {
    fn new(root: u256) -> MPT;
    fn verify(self: @MPT, proof: Span<u256>) -> Result<u256, felt252>;
    fn decode_rlp_node(rlp: u256) -> MPTNode;
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

    fn verify(self: @MPT, proof: Span<u256>) -> Result<u256, felt252> {
        let mut i: usize = 0;
        let mut current_element = 0;
        let mut current_element_hash = 0;
        let mut next_element_hash = 0;
        loop {
            if i >= proof.len() {
                break Result::Err('Proof is over');
            }

            current_element = *proof[i];
            current_element_hash = KeccakHasher::hash_single(current_element);

            if i == 0 {
                assert(current_element_hash == *self.root, 'Root not matching');
            } else {
                // TODO handle case where RLP < 32 bytes and not hashed
                assert(current_element_hash == next_element_hash, 'Element not matching');
            }

            let node = MPTTrait::decode_rlp_node(current_element);

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

    fn decode_rlp_node(rlp: u256) -> MPTNode {
        //TODO
        MPTNode::Leaf((false, 0, 0))
    }
}

#[cfg(test)]
mod tests {
    use super::{MPT, MPTTrait};
    #[test]
    fn test() {
    }
}
