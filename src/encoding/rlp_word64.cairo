use result::ResultTrait;
use option::OptionTrait;
use array::{Array, ArrayTrait, Span, SpanTrait};
use clone::Clone;
use traits::{Into, TryInto};
use cairo_lib::utils::types::bytes::{Bytes, BytesPartialEq, BytesTryIntoU256};
use cairo_lib::utils::types::byte::Byte;
use cairo_lib::utils::bitwise::{right_shift, bytes_used};
use debug::PrintTrait;

// @notice Enum with all possible RLP types
#[derive(Drop, PartialEq)]
enum RLPType {
    String: (),
    StringShort: (),
    StringLong: (),
    ListShort: (),
    ListLong: (),
}

#[generate_trait]
impl RLPTypeImpl of RLPTypeTrait {
    // @notice Returns RLPType from the leading byte
    // @param byte Leading byte
    // @return Result with RLPType
    fn from_byte(byte: Byte) -> Result<RLPType, felt252> {
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

// @notice Represent a RLP item
#[derive(Drop)]
enum RLPItemWord64 {
    Bytes: Span<u64>,
    // Should be Span<RLPItem> to allow for any depth/recursion, not yet supported by the compiler
    List: Span<Span<u64>>
}

// @notice RLP decodes a rlp encoded byte array
// @param input RLP encoded bytes
// @return Result with RLPItem and size of the decoded item
fn rlp_decode_word64(input: Span<u64>) -> Result<(RLPItemWord64, usize), felt252> {
    //let prefix = extract_byte_at(*input.at(0), 7);
    let prefix: u8 = (*input.at(0) & 0xff).try_into().unwrap();

    // Unwrap is impossible to panic here
    let rlp_type = RLPTypeTrait::from_byte(prefix).unwrap();
    match rlp_type {
        RLPType::String(()) => {
            let mut arr = array![prefix.into()];
            //prefix.print();
            Result::Ok((RLPItemWord64::Bytes(arr.span()), 1))
        },
        RLPType::StringShort(()) => {
            //let len = prefix.into();
            //let res = input.slice(1, len);

            //Result::Ok((RLPItemWord64::Bytes(res), 1 + len))
            Result::Err('Not implemented')
        },
        RLPType::StringLong(()) => {
            //let len_len = prefix.into() - 0xb7;
            //let len_span = input.slice(1, len_len);

            //// Bytes => u256 => u32
            //let len: u32 = len_span.try_into().unwrap().try_into().unwrap();
            //let res = input.slice(1 + len_len, len);

            //Result::Ok((RLPItemWord64::Bytes(res), 1 + len_len + len))
            Result::Err('Not implemented')
        },
        RLPType::ListShort(()) => {
            //let len = prefix.into() - 0xc0;
            //let mut in = input.slice(1, len);
            //let res = rlp_decode_list_word64(ref in);
            //Result::Ok((RLPItemWord64::List(res), 1 + len))
            Result::Err('Not implemented')
        },
        RLPType::ListLong(()) => {
            //let len_len = prefix.into() - 0xf7;
            //let len_span = input.slice(1, len_len);

            //// Bytes => u256 => u32
            //let len: u32 = len_span.try_into().unwrap().try_into().unwrap();
            //let mut in = input.slice(1 + len_len, len);
            //let res = rlp_decode_list_word64(ref in);
            //Result::Ok((RLPItemWord64::List(res), 1 + len_len + len))
            Result::Err('Not implemented')
        }
    }
}

//fn rlp_decode_list_word64(ref input: Bytes) -> Span<Bytes> {
    //let mut i = 0;
    //let len = input.len();
    //let mut output = ArrayTrait::new();

    //loop {
        //if i >= len {
            //break ();
        //}

        //let (decoded, decoded_len) = rlp_decode_word64(input).unwrap();
        //match decoded {
            //RLPItemWord64::Bytes(b) => {
                //output.append(b);
                //input = input.slice(decoded_len, input.len() - decoded_len);
            //},
            //RLPItemWord64::List(_) => {
                //panic_with_felt252('Recursive list not supported');
            //}
        //}
        //i += decoded_len;
    //};
    //output.span()
//}

impl SpanU64PartialEq of PartialEq<Span<u64>> {
    fn eq(lhs: @Span<u64>, rhs: @Span<u64>) -> bool {
        let len_lhs = (*lhs).len();
        if len_lhs != (*rhs).len() {
            return false;
        }

        let mut i: usize = 0;
        loop {
            if i >= len_lhs {
                break true;
            }

            if (*lhs).at(i) != (*rhs).at(i) {
                break false;
            }

            i += 1;
        }
    }

    fn ne(lhs: @Span<u64>, rhs: @Span<u64>) -> bool {
        !(lhs == rhs)
    }
}

impl RLPItemPartialEq of PartialEq<RLPItemWord64> {
    fn eq(lhs: @RLPItemWord64, rhs: @RLPItemWord64) -> bool {
        match lhs {
            RLPItemWord64::Bytes(b) => {
                match rhs {
                    RLPItemWord64::Bytes(b2) => {
                        b == b2
                    },
                    RLPItemWord64::List(_) => false
                }
            },
            RLPItemWord64::List(l) => {
                match rhs {
                    RLPItemWord64::Bytes(_) => false,
                    RLPItemWord64::List(l2) => {
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

    fn ne(lhs: @RLPItemWord64, rhs: @RLPItemWord64) -> bool {
        // TODO optimize
        !(lhs == rhs)
    }
}

