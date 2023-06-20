use array::{Array, ArrayTrait, Span, SpanTrait};
use clone::Clone;
use traits::Into;

#[derive(Drop)]
enum RLPType {
    String: (),
    StringShort: (),
    StringLong: (),
    ListShort: (),
    ListLong: (),
}

trait RLPTypeTrait {
    fn from_byte(byte: u8) -> Result<RLPType, felt252>;
}

impl RLPTypeImpl of RLPTypeTrait {
    fn from_byte(byte: u8) -> Result<RLPType, felt252> {
        if byte <= 0x7f {
            Result::Ok(RLPType::String(()))
        } else if byte <= 0xb7 {
            Result::Ok(RLPType::StringShort(()))
        } else if byte <= 0xbf {
            Result::Ok(RLPType::StringLong(()))
        } else if byte <= 0xf7 {
            Result::Ok(RLPType::ListShort(()))
        } else if byte <= 0xff {
            Result::Ok(RLPType::ListLong(()))
        } else {
            Result::Err('Invalid byte')
        }
    }
}

#[derive(Clone, Drop)]
enum RLPItem {
    Bytes: Array<u8>,
    List: Array<RLPItem>
}

fn rlp_decode(input: Span<u8>) -> Result<Array<RLPItem>, felt252> {
    let mut i: usize = 0;
    let mut output = ArrayTrait::new();

    loop {
        if i >= input.len() {
            // TODO check clone
            break Result::Ok(output.clone());
        }
        let prefix = *input[i];
        i += 1;

        let rlp_type = RLPTypeTrait::from_byte(prefix);
        match rlp_type {
            Result::Ok(t) => {
                let item = match t {
                    RLPType::String(()) => {
                        let mut arr = ArrayTrait::new();
                        arr.append(prefix);
                        RLPItem::Bytes(arr)
                    },
                    RLPType::StringShort(()) => {
                        let len = prefix - 0x80;
                        let mut j: usize = i;
                        let mut arr = ArrayTrait::new();
                        loop {
                            if j >= i + len.into() {
                                break ();
                            }

                            arr.append(*input[j]);
                            j += 1;
                        };
                        RLPItem::Bytes(arr)
                    },
                    RLPType::StringLong(()) => {
                        // TODO
                        let mut arr = ArrayTrait::new();
                        RLPItem::Bytes(arr)

                    },
                    RLPType::ListShort(()) => {
                        // TODO
                        let mut arr = ArrayTrait::new();
                        RLPItem::Bytes(arr)
                    },
                    RLPType::ListLong(()) => {
                        // TODO
                        let mut arr = ArrayTrait::new();
                        RLPItem::Bytes(arr)
                    }
                };
                output.append(item);
            },
            Result::Err(e) =>  { 
                break Result::Err(e); 
            }
        };
    }
}
