use zeroable::Zeroable;
use math::Oneable;
use traits::{Sub, Mul};

fn pow<
    T,
    impl TZeroable: Zeroable<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
>(base: T, mut exp: T) -> T {
    if exp.is_zero() {
        TOneable::one()
    } else {
        base * pow(base, exp - TOneable::one())
    }
}

fn pow_felt252(base: felt252, exp: felt252) -> felt252 {
    if exp == 0 {
        1
    } else {
        base * pow_felt252(base, exp - 1)
    }
}
