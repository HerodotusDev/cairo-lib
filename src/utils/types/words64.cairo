use array::{ArrayTrait, SpanTrait};
use cairo_lib::utils::bitwise::{left_shift, right_shift};
use traits::{Into, TryInto};
use option::OptionTrait;

type Words64 = Span<u64>;

#[generate_trait]
impl Words64Impl of Words64Trait {
    fn slice_le(self: Words64, start: usize, len: usize) -> Span<u64> {
        if len == 0 {
            return ArrayTrait::new().span();
        }

        let first_word_index = start / 8;
        // number of right bytes to remove
        let mut word_offset = 8 - ((start+1) % 8);
        if word_offset == 8 {
            word_offset = 0;
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
            let next = *self.at(i+1);

            // remove lsb bytes from the first word
            let shifted = right_shift_u64(word, word_offset.into() * 8);

            // get lsb bytes from the second word
            let mask_second_word = left_shift_u64(1, word_offset * 8) - 1;
            let bytes_to_append = next & mask_second_word.into();

            // apend bytes to msb first word
            let mask_first_word = left_shift_u64(bytes_to_append, (8 - word_offset.into()) * 8);
            let new_word = shifted | mask_first_word;

            output.append(new_word);
            i += 1;
        };


        let last_word = *self.at(i);
        let shifted = right_shift_u64(last_word, word_offset.into() * 8);

        let mut len_last_word = len % 8;
        if len_last_word == 0 {
            len_last_word = 8;
        }

        if len_last_word <= 8 - word_offset {
            // using u128 because if len_last_word == 8 left_shift might overflow by 1
            // after subtracting 1 it's safe to unwrap
            let mask: u128 = left_shift(1_u128, len_last_word.into() * 8) - 1;
            let last_word_masked = shifted & mask.try_into().unwrap();
            output.append(last_word_masked);
        } else {
            let missing_bytes = len_last_word - (8 - word_offset);
            let next = *self.at(i+1);

            // get lsb bytes from the second word
            let mask_second_word = left_shift_u64(1, missing_bytes * 8) - 1;
            let bytes_to_append = next & mask_second_word.into();

            // apend bytes to msb first word
            let mask_first_word = left_shift_u64(bytes_to_append, (8 - word_offset.into()) * 8);
            let new_word = shifted | mask_first_word;

            output.append(new_word);
        }

        output.span()
    }
}

fn pow2(pow: u32) -> u64 {
    let powers = array![0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000, 0x400000, 0x800000, 0x1000000, 0x2000000, 0x4000000, 0x8000000, 0x10000000, 0x20000000, 0x40000000, 0x80000000, 0x100000000, 0x200000000, 0x400000000, 0x800000000, 0x1000000000, 0x2000000000, 0x4000000000, 0x8000000000, 0x10000000000, 0x20000000000, 0x40000000000, 0x80000000000, 0x100000000000, 0x200000000000, 0x400000000000, 0x800000000000, 0x1000000000000, 0x2000000000000, 0x4000000000000, 0x8000000000000, 0x10000000000000, 0x20000000000000, 0x40000000000000, 0x80000000000000, 0x100000000000000, 0x200000000000000, 0x400000000000000, 0x800000000000000, 0x1000000000000000, 0x2000000000000000, 0x4000000000000000, 0x8000000000000000];
    *powers.at(pow)
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
                if val == 0 { return 0; } else { return 1; };
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

