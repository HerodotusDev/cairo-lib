use cairo_lib::utils::math::pow;
use math::Oneable;
use zeroable::Zeroable;

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
    // TODO change this logic
    let two = TOneable::one() + TOneable::one();
    num * pow(two, shift)
}

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
    // TODO change this logic
    let two = TOneable::one() + TOneable::one();
    num / pow(two, shift)
}

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
    return bit_position;
}
