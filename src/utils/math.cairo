use math::Oneable;

// @notice Computes `base ^ exp`
// @param base The base of the exponentiation
// @param exp The exponent of the exponentiation
// @return The exponentiation result

fn pow<
    T,
    impl Zeroable: Zeroable<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>,
    impl TAdd: Add<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TDiv: Div<T>,
    impl TRem: Rem<T>,
    impl TPartialEq: PartialEq<T>,
    impl TPartialOrd: PartialOrd<T>
>(
    mut base: T, mut exp: T
) -> T {
    let two = TOneable::one() + TOneable::one();
    let four = two + two;
    let sixteen = four * four;
    if exp < sixteen {
        slow_pow(base, exp)
    } else {
        fast_pow(base, exp)
    }
}

fn slow_pow<
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
        base * slow_pow(base, exp - TOneable::one())
    }
}

fn fast_pow<
    T,
    impl Zeroable: Zeroable<T>,
    impl TOneable: Oneable<T>,
    impl TCopy: Copy<T>,
    impl TDrop: Drop<T>,
    impl TAdd: Add<T>,
    impl TSub: Sub<T>,
    impl TMul: Mul<T>,
    impl TDiv: Div<T>,
    impl TRem: Rem<T>,
    impl TPartialEq: PartialEq<T>
>(
    mut base: T, mut exp: T
) -> T {
    let mut ans = TOneable::one();
    loop {
        if exp.is_zero() {
            break ans;
        }
        let two = TOneable::one() + TOneable::one();
        let mm = exp % two;
        if mm == TOneable::one() {
            ans = ans * base;
            exp = exp - TOneable::one();
        } else {
            base = base * base;
            exp = exp / two;
        };
    }
}
