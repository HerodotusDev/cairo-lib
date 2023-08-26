use array::{ArrayTrait, SpanTrait};
use cairo_lib::utils::bitwise::{right_shift_u64, left_shift_u64, left_shift};
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
