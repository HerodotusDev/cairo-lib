use core::num::traits::{Zero, One};

// @notice Computes `base ^ exp`
// @param base The base of the exponentiation
// @param exp The exponent of the exponentiation
// @return The exponentiation result

pub fn pow<
    T,
    +Zero<T>,
    +One<T>,
    +Copy<T>,
    +Drop<T>,
    +Add<T>,
    +Sub<T>,
    +Mul<T>,
    +Div<T>,
    +Rem<T>,
    +PartialEq<T>,
    +PartialOrd<T>
>(
    mut base: T, mut exp: T
) -> T {
    let two = One::one() + One::one();
    let four = two + two;
    let sixteen = four * four;
    if exp < sixteen {
        slow_pow(base, exp)
    } else {
        fast_pow(base, exp)
    }
}

pub fn slow_pow<
    T,
    +Zero<T>,
    +Sub<T>,
    +Mul<T>,
    +One<T>,
    +Copy<T>,
    +Drop<T>
>(
    base: T, mut exp: T
) -> T {
    if exp.is_zero() {
        One::one()
    } else {
        base * slow_pow(base, exp - One::one())
    }
}

pub fn fast_pow<
    T,
    +Zero<T>,
    +One<T>,
    +Copy<T>,
    +Drop<T>,
    +Add<T>,
    +Sub<T>,
    +Mul<T>,
    +Div<T>,
    +Rem<T>,
    +PartialEq<T>
>(
    mut base: T, mut exp: T
) -> T {
    let mut ans = One::one();
    loop {
        if exp.is_zero() {
            break ans;
        }
        let two = One::one() + One::one();
        let mm = exp % two;
        if mm == One::one() {
            ans = ans * base;
            exp = exp - One::one();
        } else {
            base = base * base;
            exp = exp / two;
        };
    }
}

