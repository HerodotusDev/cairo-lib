use array::{ArrayTrait, SpanTrait};
use cairo_lib::utils::bitwise::{left_shift, right_shift};
use traits::{Into, TryInto};
use option::OptionTrait;

type Words64 = Span<u64>;

impl Words64TryIntoU256LE of TryInto<Words64, u256> {
    fn try_into(self: Words64) -> Option<u256> {
        if self.len() != 4 {
            return Option::None(());
        }

        let pow2_64 = 0x10000000000000000;
        let pow2_128 = 0x100000000000000000000000000000000;
        let pow2_192 = 0x1000000000000000000000000000000000000000000000000;

        let mut output: u256 = (*self.at(0)).into();
        output = output | (*self.at(1)).into() * pow2_64;
        output = output | (*self.at(2)).into() * pow2_128;
        output = output | (*self.at(3)).into() * pow2_192;
        Option::Some(output)
    }
}

#[generate_trait]
impl Words64Impl of Words64Trait {
    fn slice_le(self: Words64, start: usize, len: usize) -> Span<u64> {
        if len == 0 {
            return ArrayTrait::new().span();
        }

        let first_word_index = start / 8;
        // number of right bytes to remove
        let mut word_offset_bytes = 8 - ((start + 1) % 8);
        if word_offset_bytes == 8 {
            word_offset_bytes = 0;
        }

        let word_offset_bits = word_offset_bytes * 8;
        let pow2_word_offset_bits = pow2(word_offset_bits);
        let mask_second_word = pow2_word_offset_bits - 1;
        let reverse_words_offset_bits = 64 - word_offset_bits;

        let mut pow2_reverse_words_offset_bits = 0;
        if word_offset_bytes != 0 {
            pow2_reverse_words_offset_bits = pow2(reverse_words_offset_bits);
        }

        let mut output_words = len / 8;
        if len % 8 != 0 {
            output_words += 1;
        }

        let mut output = ArrayTrait::new();
        let mut i = first_word_index;
        loop {
            if i - first_word_index == output_words - 1 {
                break ();
            }
            let word = *self.at(i);
            let next = *self.at(i + 1);

            // remove bytes from the right
            let shifted = word / pow2_word_offset_bits;

            // get right bytes from the next word
            let bytes_to_append = next & mask_second_word;

            // apend bytes to the left of first word
            let mask_first_word = bytes_to_append * pow2_reverse_words_offset_bits;
            let new_word = shifted | mask_first_word;

            output.append(new_word);
            i += 1;
        };

        let last_word = *self.at(i);
        let shifted = last_word / pow2_word_offset_bits;

        let mut len_last_word = len % 8;
        if len_last_word == 0 {
            len_last_word = 8;
        }

        if len_last_word <= 8 - word_offset_bytes {
            // using u128 because if len_last_word == 8 left_shift might overflow by 1
            // after subtracting 1 it's safe to unwrap
            let mask: u128 = left_shift(1_u128, len_last_word.into() * 8) - 1;
            let last_word_masked = shifted & mask.try_into().unwrap();
            output.append(last_word_masked);
        } else {
            let missing_bytes = len_last_word - (8 - word_offset_bytes);
            let next = *self.at(i + 1);

            // get right bytes from the next word
            let mask_second_word = left_shift_u64(1, missing_bytes * 8) - 1;
            let bytes_to_append = next & mask_second_word;

            // apend bytes to the left of first word
            let mask_first_word = bytes_to_append * pow2_reverse_words_offset_bits;
            let new_word = shifted | mask_first_word;

            output.append(new_word);
        }

        output.span()
    }
}

fn left_shift_u64(num: u64, shift: usize) -> u64 {
    num * pow2(shift)
}

fn right_shift_u64(num: u64, shift: usize) -> u64 {
    num / pow2(shift)
}

fn bytes_used(val: u64) -> usize {
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

fn reverse_endianness(input: u64, significant_bytes: Option<u64>) -> u64 {
    let sb = match significant_bytes {
        Option::Some(x) => x,
        Option::None(()) => 56
    };

    let mut reverse = 0;
    let mut i = 0;
    loop {
        if i == sb {
            break reverse;
        }

        let r_shift = right_shift(input, (i * 8)) & 0xff;
        reverse = reverse | left_shift(r_shift, (sb - i - 1) * 8);

        i += 1;
    }
}

fn pow2(pow: usize) -> u64 {
    if pow == 0 {
        return 0x1;
    } else if pow == 1 {
        return 0x2;
    } else if pow == 2 {
        return 0x4;
    } else if pow == 3 {
        return 0x8;
    } else if pow == 4 {
        return 0x10;
    } else if pow == 5 {
        return 0x20;
    } else if pow == 6 {
        return 0x40;
    } else if pow == 7 {
        return 0x80;
    } else if pow == 8 {
        return 0x100;
    } else if pow == 9 {
        return 0x200;
    } else if pow == 10 {
        return 0x400;
    } else if pow == 11 {
        return 0x800;
    } else if pow == 12 {
        return 0x1000;
    } else if pow == 13 {
        return 0x2000;
    } else if pow == 14 {
        return 0x4000;
    } else if pow == 15 {
        return 0x8000;
    } else if pow == 16 {
        return 0x10000;
    } else if pow == 17 {
        return 0x20000;
    } else if pow == 18 {
        return 0x40000;
    } else if pow == 19 {
        return 0x80000;
    } else if pow == 20 {
        return 0x100000;
    } else if pow == 21 {
        return 0x200000;
    } else if pow == 22 {
        return 0x400000;
    } else if pow == 23 {
        return 0x800000;
    } else if pow == 24 {
        return 0x1000000;
    } else if pow == 25 {
        return 0x2000000;
    } else if pow == 26 {
        return 0x4000000;
    } else if pow == 27 {
        return 0x8000000;
    } else if pow == 28 {
        return 0x10000000;
    } else if pow == 29 {
        return 0x20000000;
    } else if pow == 30 {
        return 0x40000000;
    } else if pow == 31 {
        return 0x80000000;
    } else if pow == 32 {
        return 0x100000000;
    } else if pow == 33 {
        return 0x200000000;
    } else if pow == 34 {
        return 0x400000000;
    } else if pow == 35 {
        return 0x800000000;
    } else if pow == 36 {
        return 0x1000000000;
    } else if pow == 37 {
        return 0x2000000000;
    } else if pow == 38 {
        return 0x4000000000;
    } else if pow == 39 {
        return 0x8000000000;
    } else if pow == 40 {
        return 0x10000000000;
    } else if pow == 41 {
        return 0x20000000000;
    } else if pow == 42 {
        return 0x40000000000;
    } else if pow == 43 {
        return 0x80000000000;
    } else if pow == 44 {
        return 0x100000000000;
    } else if pow == 45 {
        return 0x200000000000;
    } else if pow == 46 {
        return 0x400000000000;
    } else if pow == 47 {
        return 0x800000000000;
    } else if pow == 48 {
        return 0x1000000000000;
    } else if pow == 49 {
        return 0x2000000000000;
    } else if pow == 50 {
        return 0x4000000000000;
    } else if pow == 51 {
        return 0x8000000000000;
    } else if pow == 52 {
        return 0x10000000000000;
    } else if pow == 53 {
        return 0x20000000000000;
    } else if pow == 54 {
        return 0x40000000000000;
    } else if pow == 55 {
        return 0x80000000000000;
    } else if pow == 56 {
        return 0x100000000000000;
    } else if pow == 57 {
        return 0x200000000000000;
    } else if pow == 58 {
        return 0x400000000000000;
    } else if pow == 59 {
        return 0x800000000000000;
    } else if pow == 60 {
        return 0x1000000000000000;
    } else if pow == 61 {
        return 0x2000000000000000;
    } else if pow == 62 {
        return 0x4000000000000000;
    } else if pow == 63 {
        return 0x80000000000000;
    } else {
        return 0;
    }
}

