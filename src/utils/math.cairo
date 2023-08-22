use zeroable::Zeroable;
use math::Oneable;
use traits::{Sub, Mul};

trait Exponentiation<T> {
    /// Raise a number to a power.
    /// * `self` - The number to raise.
    /// * `exp` - The exponent.
    /// # Returns
    /// * `T` - The result of base raised to the power of exp.
    fn pow(self: T, exp: T) -> T;
}


impl Felt252ExpImpl of Exponentiation<felt252> {
    fn pow(self: felt252, exp: felt252) -> felt252 {
        if self == 0 {
            return 0;
        }
        if exp == 0 {
            return 1;
        } else {
            return self * Exponentiation::pow(self, exp - 1);
        }
    }
}

impl TExponentiation<
    T,
    impl TZeroable: Zeroable<T>,
    impl TOneable: Oneable<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>,
> of Exponentiation<T> {
    fn pow(self: T, exp: T) -> T {
        if self.is_zero() {
            return TZeroable::zero();
        }
        if exp.is_zero() {
            return TOneable::one();
        } else {
            return self * Exponentiation::pow(self, exp - TOneable::one());
        }
    }
}
