use result::ResultTrait;
use option::OptionTrait;
use array::{Array, ArrayTrait, Span, SpanTrait};
use traits::{Into, TryInto};
use cairo_lib::utils::types::words64::{Words64, Words64Trait, reverse_endianness, Words64PartialEq};
use cairo_lib::utils::types::byte::Byte;
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
    Bytes: Words64,
    // Should be Span<RLPItem> to allow for any depth/recursion, not yet supported by the compiler
    List: Span<Words64>
}

// @notice RLP decodes a rlp encoded byte array
// @param input RLP encoded bytes
// @return Result with RLPItem and size of the decoded item
fn rlp_decode_word64(input: Words64) -> Result<(RLPItemWord64, usize), felt252> {
    let prefix: u32  = (*input.at(0) & 0xff).try_into().unwrap();

    // Unwrap is impossible to panic here
    let rlp_type = RLPTypeTrait::from_byte(prefix.try_into().unwrap()).unwrap();
    match rlp_type {
        RLPType::String(()) => {
            let mut arr = array![prefix.into()];
            Result::Ok((RLPItemWord64::Bytes(arr.span()), 1))
        },
        RLPType::StringShort(()) => {
            let len = prefix.into() - 0x80;
            let res = input.slice_le(6, len);

            Result::Ok((RLPItemWord64::Bytes(res), 1 + len))
        },
        RLPType::StringLong(()) => {
            let len_len = prefix - 0xb7;
            let len_span = input.slice_le(6, len_len);
            // Enough to store 4.29 GB (fits in u32)
            assert(len_span.len() == 1 && *len_span.at(0) <= 0xffffffff, 'Len of len too big');

            // len fits in 32 bits, confirmed by previous assertion
            let len: u32 = reverse_endianness(*len_span.at(0), Option::Some(len_len.into()))
                .try_into()
                .unwrap();
            let res = input.slice_le(6 - len_len, len);

            Result::Ok((RLPItemWord64::Bytes(res), 1 + len_len + len))
        },
        RLPType::ListShort(()) => {
            let mut len = prefix - 0xc0;
            let mut in = input.slice_le(6, len);
            let res = rlp_decode_list_word64(ref in, len);
            Result::Ok((RLPItemWord64::List(res), 1 + len))
        },
        RLPType::ListLong(()) => {
            let len_len = prefix - 0xf7;
            let len_span = input.slice_le(6, len_len);
            // Enough to store 4.29 GB (fits in u32)
            assert(len_span.len() == 1 && *len_span.at(0) <= 0xffffffff, 'Len of len too big');

            // len fits in 32 bits, confirmed by previous assertion
            let len: u32 = reverse_endianness(*len_span.at(0), Option::Some(len_len.into()))
                .try_into()
                .unwrap();
            let mut in = input.slice_le(6 - len_len, len);
            let res = rlp_decode_list_word64(ref in, len);

            Result::Ok((RLPItemWord64::List(res), 1 + len_len + len))
        }
    }
}

fn rlp_decode_list_word64(ref input: Words64, len: usize) -> Span<Words64> {
    let mut i = 0;
    let mut output = ArrayTrait::new();
    let mut total_len = len;

    loop {
        if i >= len {
            break ();
        }

        let (decoded, decoded_len) = rlp_decode_word64(input).unwrap();
        match decoded {
            RLPItemWord64::Bytes(b) => {
                output.append(b);
                let word = decoded_len / 8;
                let reversed = 7 - (decoded_len % 8);
                let next_start = word * 8 + reversed;
                if (total_len - decoded_len != 0) {
                    input = input.slice_le(next_start, total_len - decoded_len);
                }
                total_len -= decoded_len;
            },
            RLPItemWord64::List(_) => {
                panic_with_felt252('Recursive list not supported');
            }
        }
        i += decoded_len;
    };
    output.span()
}

impl RLPItemWord64PartialEq of PartialEq<RLPItemWord64> {
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

