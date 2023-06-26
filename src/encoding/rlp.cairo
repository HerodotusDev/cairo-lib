use result::ResultTrait;
use option::OptionTrait;
use array::{Array, ArrayTrait, Span, SpanTrait};
use clone::Clone;
use traits::{Into, TryInto};
use cairo_lib::utils::types::{Bytes, BytesPartialEq, BytesTryIntoU256};
use debug::PrintTrait;

#[derive(Drop, PartialEq)]
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

#[derive(Drop)]
enum RLPItem {
    Bytes: Bytes,
    // Should be Array<RLPItem> to allow for any depth , but compiler panic
    List: Span<Bytes>
}

fn rlp_decode(ref input: Bytes) -> Result<(RLPItem, usize), felt252> {
    let prefix = *input.at(0);

    // Unwrap is impossible to panic here
    let rlp_type = RLPTypeTrait::from_byte(prefix).unwrap();
    match rlp_type {
        RLPType::String(()) => {
            let mut arr = ArrayTrait::new();
            arr.append(prefix);
            Result::Ok((RLPItem::Bytes(arr.span()), 1))
        },
        RLPType::StringShort(()) => {
            let len = prefix - 0x80;
            let mut i: usize = 1;
            let mut arr = ArrayTrait::new();
            loop {
                if i >= 1 + len.into() {
                    break ();
                }

                arr.append(*input[i]);
                i += 1;
            };

            Result::Ok((RLPItem::Bytes(arr.span()), 1 + len.into()))
        },
        RLPType::StringLong(()) => {
            let len_len = prefix - 0xb7;
            let mut i: usize = 1;
            let mut len_arr = ArrayTrait::new();
            loop {
                if i >= 1 + len_len.into() {
                    break ();
                }

                len_arr.append(*input[i]);
                i += 1;
            };

            // TODO handle error of byte conversion
            // TODO handle error of converting u256 to u32
            // If RLP is correclty formated it should never fail, so using unwrap for now
            let len: u32 = len_arr.span().try_into().unwrap().try_into().unwrap();

            let mut arr = ArrayTrait::new(); 
            i = 1 + len_len.into();
            loop {
                if i >= 1 + len_len.into() + len {
                    break ();
                }

                arr.append(*input[i]);
                i += 1;
            };

            Result::Ok((RLPItem::Bytes(arr.span()), 1 + len_len.into() + len))
        },
        RLPType::ListShort(()) => {
            let len = prefix - 0xc0;
            let mut i: usize = 1;
            let mut arr = ArrayTrait::new();
            loop {
                if i >= 1 + len.into() {
                    break ();
                }

                let (decoded, decoded_len) = rlp_decode(ref input).unwrap();
                match decoded {
                    RLPItem::Bytes(b) => {
                        arr.append(b);
                        let mut j = 0;
                        loop {
                            if j > b.len() {
                                break ();
                            }
                            input.pop_front();
                        };
                    },
                    RLPItem::List(_) => {
                        // TODO return Err
                        panic_with_felt252('Recursive list not supported');
                        // return Result::Err('Recursive list not supported');
                    }
                }
                i += decoded_len;
            };
            Result::Ok((RLPItem::List(arr.span()), 1 + len.into()))
        },
        RLPType::ListLong(()) => {
            let len_len = prefix - 0xb7;
            let mut i: usize = 1;
            let mut len_arr = ArrayTrait::new();
            loop {
                if i >= 1 + len_len.into() {
                    break ();
                }

                len_arr.append(*input[i]);
                i += 1;
            };

            // TODO handle error of byte conversion
            // TODO handle error of converting u256 to u32
            // If RLP is correclty formated it should never fail, so using unwrap for now
            let len: u32 = len_arr.span().try_into().unwrap().try_into().unwrap();
            let mut i: usize = 1;
            let mut arr = ArrayTrait::new();
            loop {
                if i >= 1 + len.into() {
                    break ();
                }

                let (decoded, decoded_len) = rlp_decode(ref input).unwrap();
                match decoded {
                    RLPItem::Bytes(b) => {
                        arr.append(b);
                        let mut j = 0;
                        loop {
                            if j > b.len() {
                                break ();
                            }
                            input.pop_front();
                        };
                    },
                    RLPItem::List(_) => {
                        // TODO return Err
                        panic_with_felt252('Recursive list not supported');
                        // return Result::Err('Recursive list not supported');
                    }
                }
                i += decoded_len;
            };
            Result::Ok((RLPItem::List(arr.span()), 1 + len_len.into() + len))
        }
    }
}

impl RLPItemPartialEq of PartialEq<RLPItem> {
    fn eq(lhs: @RLPItem, rhs: @RLPItem) -> bool {
        match lhs {
            RLPItem::Bytes(b) => {
                match rhs {
                    RLPItem::Bytes(b2) => {
                        b == b2
                    },
                    RLPItem::List(_) => false
                }
            },
            RLPItem::List(l) => {
                match rhs {
                    RLPItem::Bytes(_) => false,
                    RLPItem::List(l2) => {
                        let len_l = (*l).len();
                        if len_l != (*l2).len() {
                            return false;
                        }
                        let mut i: usize = 0;
                        loop {
                            if i >= len_l {
                                break true;
                            }
                            if (*l).at(i) != (*l2).at(i) {
                                break false;
                            }
                            i += 1;
                        }
                    }
                }
            }
        }
    }

    fn ne(lhs: @RLPItem, rhs: @RLPItem) -> bool {
        // TODO optimize
        !(lhs == rhs)
    }
}

