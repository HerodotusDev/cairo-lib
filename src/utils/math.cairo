use math::Oneable;

// @notice Computes `base ^ exp`
// @param base The base of the exponentiation
// @param exp The exponent of the exponentiation
// @return The exponentiation result
fn pow<
    T,
    impl TZeroable: Zeroable<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>
>(
    base: T, mut exp: T
) -> T {
    if exp.is_zero() {
        TOneable::one()
    } else {
        base * pow(base, exp - TOneable::one())
    }
}
