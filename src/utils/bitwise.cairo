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
>(num: T, shift: T) -> T {
    // TODO change this logic
    let two = TOneable::one() + TOneable::one();
    num * pow(two, shift)
}
