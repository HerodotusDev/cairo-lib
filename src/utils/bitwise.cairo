use cairo_lib::utils::math::{pow, pow_felt252};
use cairo_lib::utils::types::byte::Byte;
use math::Oneable;
use zeroable::Zeroable;
use option::OptionTrait;
use traits::{TryInto, Into};
use array::{SpanTrait, ArrayTrait};
use debug::PrintTrait;

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

