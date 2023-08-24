use cairo_lib::utils::math::{pow, pow_felt252};
use cairo_lib::utils::types::byte::Byte;
use math::Oneable;
use zeroable::Zeroable;
use option::OptionTrait;
use traits::{TryInto, Into};
use array::{SpanTrait, ArrayTrait};
use debug::PrintTrait;

// @notice Bitwise left shift
// @param num The number to be shifted
// @param shift The number of bits to shift
// @return The left shifted number
fn left_shift<
    T,
    impl TZeroable: Zeroable<T>,
    impl TAdd: Add<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
// TODO refactor shift type from T to usize
>(
    num: T, shift: T
) -> T {
    let two = TOneable::one() + TOneable::one();
    num * pow(two, shift)
}

fn left_shift_felt252(num: felt252, shift: felt252) -> felt252 {
    num * pow_felt252(2, shift)
}

// @notice Bitwise right shift
// @param num The number to be shifted
// @param shift The number of bits to shift
// @return The right shifted number
fn right_shift<
    T,
    impl TZeroable: Zeroable<T>,
    impl TAdd: Add<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TDiv: Div<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
// TODO refactor shift type from T to usize
>(
    num: T, shift: T
) -> T {
    let two = TOneable::one() + TOneable::one();
    num / pow(two, shift)
}

// @notice Bit length of a number
// @param num The number to be measured
// @return The number of bits in the number
fn bit_length<
    T,
    impl TZeroable: Zeroable<T>,
    impl TPartialOrd: PartialOrd<T>,
    impl TAddImpl: Add<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
>(
    num: T
) -> T {
    let mut bit_position = TZeroable::zero();
    let mut cur_n = TOneable::one();
    loop {
        if cur_n > num {
            break ();
        };
        bit_position = bit_position + TOneable::one();
        cur_n = left_shift(cur_n, TOneable::one());
    };
    bit_position
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

//fn extract_byte_at(input: u64, index: u64) -> Byte {
    //let shift = right_shift(input, (56 - (index * 8)));
    //(shift & 0xff).try_into().unwrap()
//}

//fn remove_bytes_from_start(input: u64, num_bytes: u64) -> u64 {
    //left_shift(input, (num_bytes * 8))
//}

//fn add_bytes_to_start(input: u64, bytes: u64, num_bytes: u64) -> u64 {
    //let shift = left_shift(input, (num_bytes * 8));
    //let mask = left_shift(1, (num_bytes * 8)) - 1;

    //shift | (bytes & mask)
//}

//fn add_bytes_to_end(input: u64, bytes: u64, num_bytes: u64) -> u64 {
    //let shift = left_shift(input, (num_bytes * 8));
    //let mask = left_shift(1, (num_bytes * 8)) - 1;

    //shift | (bytes & mask)
//}

//fn reverse_endianness(input: u64) -> u64 {
    //let mut reverse = 0;
    //let mut i = 0;
    //loop {
        //if i == 8 {
            //break reverse;
        //}

        //let r_shift = right_shift(input, (i * 8)) & 0xff;
        //reverse = reverse | left_shift(r_shift, (56 - (i * 8)));

        //i += 1;
    //}
//}

// len in bytes, words in le
fn slice_words64(input: Span<u64>, start: usize, len: usize) -> Span<u64> {
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
        let word = *input.at(i);
        let next = *input.at(i+1);

        // remove lsb bytes from the first word
        let shifted = right_shift(word, word_offset.into() * 8);

        // get lsb bytes from the second word
        let mask_second_word = left_shift(1, word_offset * 8) - 1;
        let bytes_to_append = next & mask_second_word.into();

        // apend bytes to msb first word
        let mask_first_word = left_shift(bytes_to_append, (8 - word_offset.into()) * 8);
        let new_word = shifted | mask_first_word;

        output.append(new_word);
        i += 1;
    };


    let last_word = *input.at(i);
    let shifted = right_shift(last_word, word_offset.into() * 8);

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
        let next = *input.at(i+1);

        // get lsb bytes from the second word
        let mask_second_word = left_shift(1, missing_bytes * 8) - 1;
        let bytes_to_append = next & mask_second_word.into();

        // apend bytes to msb first word
        let mask_first_word = left_shift(bytes_to_append, (8 - word_offset.into()) * 8);
        let new_word = shifted | mask_first_word;

        output.append(new_word);
    }

    output.span()
}
