use array::SpanTrait;
use traits::{Into, TryInto};
use option::OptionTrait;
use hash::LegacyHash;
use cairo_lib::utils::types::bitarr::{BitArr, BitArrTryIntoFelt252};

struct StarkMPT {
    root: felt252
}

impl StarkMPTDefault of Default<StarkMPT> {
    fn default() -> StarkMPT {
        StarkMPTTrait::new(0)
    }
}

#[derive(Drop)]
enum StarkMPTNode {
    // left, right
    Binary: (felt252, felt252),
    // child, path
    Edge: (felt252, BitArr),
}

#[generate_trait]
impl StarkMPTNodeImpl of StarkMPTNodeTrait {
    fn hash(self: @StarkMPTNode) -> felt252 {
        match self {
            StarkMPTNode::Binary((left, right)) => {
                LegacyHash::hash(*left, *right)
            },
            StarkMPTNode::Edge((child, path)) => {
                let path_felt252: felt252 = (*path).try_into().unwrap();
                LegacyHash::hash(*child, path_felt252) + (*path).len().into()
            }
        }
    }
}

#[derive(Drop)]
enum Direction {
    Left: (),
    Right: ()
}

impl BoolIntoDirection of Into<bool, Direction> {
    fn into(self: bool) -> Direction {
        if self {
            Direction::Right
        } else {
            Direction::Left
        }
    }
}

#[generate_trait]
impl StarkMPTImpl of StarkMPTTrait {
    fn new(root: felt252) -> StarkMPT {
        StarkMPT { root: root }
    }

    fn verify(self: @StarkMPT, key: BitArr, proof: Span<StarkMPTNode>) -> Result<felt252, felt252> {
        if key.len() != 251 {
            return Result::Err('Ill-formed key');
        }

        let mut expected_hash = *self.root;
        let mut remaining_path = key;

        let mut i: usize = 0;
        loop {
            if i == proof.len() {
                break Result::Ok(expected_hash);
            }

            let node = proof.at(i);
            if node.hash() != expected_hash {
                break Result::Err('Invalid proof');
            }

            match node {
                StarkMPTNode::Binary((left, right)) => {
                    let direction: Direction = (*remaining_path.pop_front().unwrap()).into();

                    expected_hash = match direction {
                        Direction::Left => *left,
                        Direction::Right => *right,
                    };
                },
                StarkMPTNode::Edge((child, path)) => {
                    let path_len = (*path).len();
                    if path_len > remaining_path.len() {
                        break Result::Err('Invalid path');
                    }

                    let mut j: usize = 0;
                    let valid_path = loop {
                        if j == path_len {
                            break true;
                        }

                        if *remaining_path.at(j) != *(*path).at(j) {
                            break false;
                        }

                        j += 1;
                    };
                    if !valid_path {
                        break Result::Err('Invalid path');
                    }

                    expected_hash = *child;
                    remaining_path = remaining_path.slice(0, path_len);
                }
            };
            i += 1;
        }
    }
}
