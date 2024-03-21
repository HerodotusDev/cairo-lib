use cairo_lib::utils::math::pow;
use cairo_lib::utils::types::byte::Byte;
use math::Oneable;

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
    impl TDrop: Drop<T>,
    impl TDiv: Div<T>,
    impl TRem: Rem<T>,
    impl TPartialEq: PartialEq<T>,
    impl TPartialOrd: PartialOrd<T>
>(
    num: T, shift: T
) -> T {
    let two = TOneable::one() + TOneable::one();
    num * pow(two, shift)
}

// @notice Bitwise right shift
// @param num The number to be shifted
// @param shift The number of bits to shift
// @return The right shifted number
fn right_shift<
    T,
    impl TZeroable: Zeroable<T>,
    impl TOneable: Oneable<T>,
    impl TAdd: Add<T>,
    impl TSub: Sub<T>,
    impl TDiv: Div<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
>(
    num: T, shift: T
) -> T {
    let mut num = num;
    let mut shift = shift;
    let two = TOneable::one() + TOneable::one();

    loop {
        if shift.is_zero() {
            break num;
        }
        num = num / two;
        shift = shift - TOneable::one();
    }
}

// @notice Bit length of a number
// @param num The number to be measured
// @return The number of bits in the number
fn bit_length<
    T,
    impl TZeroable: Zeroable<T>,
    impl TOneable: Oneable<T>,
    impl TAddImpl: Add<T>,
    impl TDiv: Div<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
>(
    num: T
) -> T {
    let mut bit_position = TZeroable::zero();
    let mut cur_n = num;
    let two = TOneable::one() + TOneable::one();

    loop {
        if cur_n.is_zero() {
            break ();
        };
        bit_position = bit_position + TOneable::one();
        cur_n = cur_n / two;
    };
    bit_position
}

// @notice Reverse the endianness of a u256
// @param num The number to be reversed
// @return The reversed number
fn reverse_endianness_u256(num: u256) -> u256 {
    let pow2_8 = 0x100;
    let pow2_16 = 0x10000;
    let pow2_32 = 0x100000000;
    let pow2_64 = 0x10000000000000000;
    let pow2_128 = 0x100000000000000000000000000000000;

    let mut out = num;

    // swap bytes
    out = ((out & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) / pow2_8)
        | ((out & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) * pow2_8);

    // swap 2-byte long pairs
    out = ((out & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) / pow2_16)
        | ((out & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) * pow2_16);

    // swap 4-byte long pairs
    out = ((out & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) / pow2_32)
        | ((out & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) * pow2_32);

    // swap 8-byte long pairs
    out = ((out & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) / pow2_64)
        | ((out & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) * pow2_64);

    // swap 16-byte long pairs
    // Need to mask the low 128 bits to prevent overlfow when left shifting
    (out / pow2_128)
        | ((out & 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) * pow2_128)
}
