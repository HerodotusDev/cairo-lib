use core::option::OptionTrait;
use cairo_lib::utils::bitwise::left_shift;
use cairo_lib::utils::math::pow;

// @notice Represents a span of 64 bit words
// @dev In many cases it's expected that the words are in little endian, but the overall order is big endian
// Example: 0x34957c6d8a83f9cff74578dea9 is represented as [0xcff9838a6d7c9534, 0xa9de7845f7]
type Words64 = Span<u64>;

#[generate_trait]
impl Words64Impl of Words64Trait {
    // @notice Converts little endian 64 bit words to a big endian u256
    // @param bytes_used The number of bytes used
    // @return The big endian u256 representation of the words
    fn as_u256_be(self: Words64, bytes_used: usize) -> Result<u256, felt252> {
        let len = self.len();

        if len > 4 {
            return Result::Err('Too many words');
        }

        if len == 0 || bytes_used == 0 {
            return Result::Ok(0);
        }

        let mut len_last_word = bytes_used % 8;
        if len_last_word == 0 {
            len_last_word = 8;
        }

        let mut output: u256 = reverse_endianness_u64(
            (*self.at(len - 1)), Option::Some(len_last_word)
        )
            .into();

        let word_pow2 = 0x10000000000000000; // 2 ** 64
        let mut current_pow2: u256 = if len_last_word == 8 {
            word_pow2
        } else {
            pow2(len_last_word * 8).into()
        };

        let mut i = 1;
        loop {
            if i == len {
                break Result::Ok(output);
            }

            output = output
                | (reverse_endianness_u64(*self.at(len - i - 1), Option::None(())).into()
                    * current_pow2);

            if i < len - 1 {
                current_pow2 = current_pow2 * word_pow2;
            }

            i += 1;
        }
    }

    // @notice Converts little endian 64 bit words to a little endian u256 using the first 4 64 bits words
    // @return The little endian u256 representation of the words
    fn as_u256_le(self: Words64) -> Result<u256, felt252> {
        let word_pow2 = 0x10000000000000000; // 2 ** 64

        let w0: u128 = match self.get(0) {
            Option::Some(x) => { (*x.unbox()).into() },
            Option::None => { 0 }
        };
        let w1: u128 = match self.get(1) {
            Option::Some(x) => { (*x.unbox()).into() },
            Option::None => { 0 }
        };

        let w2: u128 = match self.get(2) {
            Option::Some(x) => { (*x.unbox()).into() },
            Option::None => { 0 }
        };

        let w3: u128 = match self.get(3) {
            Option::Some(x) => { (*x.unbox()).into() },
            Option::None => { 0 }
        };

        let res = u256 { low: w0 + w1 * word_pow2, high: w2 + w3 * word_pow2 };
        return Result::Ok(res);
    }

    // @notice Slices 64 bit little endian words from a starting byte and a length
    // @param start The starting byte
    // The starting byte is counted from the left. Example: 0xabcdef -> byte 0 is 0xab, byte 1 is 0xcd...
    // @param len The number of bytes to slice
    // @return A span of 64 bit little endian words
    // Example: 
    // words: [0xabcdef1234567890, 0x7584934785943295, 0x48542576]
    // start: 5 | len: 17
    // output: [0x3295abcdef123456, 0x2576758493478594, 0x54]
    fn slice_le(self: Words64, start: usize, len: usize) -> Words64 {
        if len == 0 {
            return ArrayTrait::new().span();
        }
        let (q, n_ending_bytes) = DivRem::div_rem(
            len, TryInto::<usize, NonZero<usize>>::try_into(8).unwrap()
        );

        let mut n_words = 0;
        if q == 0 {
            if n_ending_bytes == 0 {
                // 0 bytes to extract
                return ArrayTrait::new().span();
            } else {
                // 1 to 7 bytes to extract
                n_words = 1;
            }
        } else {
            if n_ending_bytes == 0 {
                n_words = q;
            } else {
                n_words = q + 1;
            }
        }

        let start_index = start / 8;
        let start_offset = (8 - ((start + 1) % 8)) % 8;

        if start_offset == 0 {
            // Handle trivial case where start offset is 0, words can be copied directly
            let copy = self.slice(start_index, q);
            let mut output: Array<u64> = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i == q {
                    break;
                }
                output.append(*copy.at(i));
                i += 1;
            };
            if (n_ending_bytes != 0) {
                let last_word: u64 = *self.at(start_index + q) / (pow2(8 * n_ending_bytes)).into();
                output.append(last_word);
                return output.span();
            }

            return output.span();
        }

        let pow_cut: u64 = pow2(8 * start_offset);
        let pow_acc: u64 = pow2(64 - 8 * start_offset);

        let mut current_word: u64 = (*self.at(start_index) / pow_cut);
        let mut output: Array<u64> = ArrayTrait::new();

        if n_words == 1 {
            let avl_bytes_in_first_word = 8 - start_offset;
            let needs_next_word = len > avl_bytes_in_first_word;
            if needs_next_word == false {
                let last_word: u64 = (current_word % pow2(8 * n_ending_bytes)).into();
                output.append(last_word);
                return output.span();
            } else {
                let last_word: u64 = (*self
                    .at(start_index + 1) % pow2(8 * (len + start_offset - 8))
                    .into());
                output.append(current_word + last_word * pow_acc.into());
                return output.span();
            }
        }

        let mut n_words_to_handle_in_loop = n_words;
        if n_ending_bytes != 0 {
            n_words_to_handle_in_loop = n_words_to_handle_in_loop - 1;
        }

        let mut i = 1;
        let mut n_words_handled = 0;
        loop {
            if n_words_handled == n_words_to_handle_in_loop {
                break;
            }
            let (q, r) = DivRem::div_rem(*self.at(start_index + i), pow_cut.try_into().unwrap());
            output.append(current_word + r * pow_acc);
            current_word = q;
            n_words_handled += 1;
            i += 1;
        };

        if n_ending_bytes != 0 {
            let current_word = *self.at(start_index + n_words_handled) / pow_cut;
            let avl_bytes_in_next_word = 8 - start_offset;
            let needs_next_word = n_ending_bytes > avl_bytes_in_next_word;
            if needs_next_word == false {
                let last_word: u64 = (current_word % pow2(8 * n_ending_bytes).into()).into();
                output.append(last_word);
                return output.span();
            } else {
                let last_word: u64 = (*self
                    .at(
                        start_index + n_words_handled + 1
                    ) % pow2(8 * (n_ending_bytes + start_offset - 8))
                    .into());
                output.append(current_word + last_word * pow_acc.into());
                return output.span();
            }
        }
        output.span()
    }
}

// @notice The number of bytes used to represent a u64
// @param val The value to check
// @return The number of bytes used to represent the value
// Example: 0xabcd -> 2
fn bytes_used_u64(val: u64) -> usize {
    if val < 4294967296 { // 256^4
        if val < 65536 { // 256^2
            if val < 256 { // 256^1
                if val == 0 {
                    return 0;
                } else {
                    return 1;
                };
            }
            return 2;
        }
        if val < 16777216 { // 256^3
            return 3;
        }
        return 4;
    } else {
        if val < 281474976710656 { // 256^6
            if val < 1099511627776 { // 256^5
                return 5;
            }
            return 6;
        }
        if val < 72057594037927936 { // 256^7
            return 7;
        }
        return 8;
    }
}

// @notice Reverses the endianness of a u64
// @param input The value to reverse
// @param significant_bytes The number of bytes to reverse
// @return The reversed value
fn reverse_endianness_u64(input: u64, significant_bytes: Option<u32>) -> u64 {
    let sb = match significant_bytes {
        Option::Some(x) => x,
        Option::None(()) => 8
    };

    let mut reverse = 0;
    let mut i = 0;
    loop {
        if i == sb {
            break reverse;
        }

        let r_shift = (input / pow2(i * 8)) & 0xff;
        reverse = reverse | (r_shift * pow2((sb - i - 1) * 8));

        i += 1;
    }
}

fn pow2(pow: usize) -> u64 {
    *[
        0x1,
        0x2,
        0x4,
        0x8,
        0x10,
        0x20,
        0x40,
        0x80,
        0x100,
        0x200,
        0x400,
        0x800,
        0x1000,
        0x2000,
        0x4000,
        0x8000,
        0x10000,
        0x20000,
        0x40000,
        0x80000,
        0x100000,
        0x200000,
        0x400000,
        0x800000,
        0x1000000,
        0x2000000,
        0x4000000,
        0x8000000,
        0x10000000,
        0x20000000,
        0x40000000,
        0x80000000,
        0x100000000,
        0x200000000,
        0x400000000,
        0x800000000,
        0x1000000000,
        0x2000000000,
        0x4000000000,
        0x8000000000,
        0x10000000000,
        0x20000000000,
        0x40000000000,
        0x80000000000,
        0x100000000000,
        0x200000000000,
        0x400000000000,
        0x800000000000,
        0x1000000000000,
        0x2000000000000,
        0x4000000000000,
        0x8000000000000,
        0x10000000000000,
        0x20000000000000,
        0x40000000000000,
        0x80000000000000,
        0x100000000000000,
        0x200000000000000,
        0x400000000000000,
        0x800000000000000,
        0x1000000000000000,
        0x2000000000000000,
        0x4000000000000000,
        0x8000000000000000,
    ].span().at(pow)
}
