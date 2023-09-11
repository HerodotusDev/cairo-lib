// @notice Check if a span contains a given value
// @param arr The span to search
// @param val The value to search for
// @return True if the span contains the value, false otherwise
fn span_contains<T, impl TDrop: Drop<T>, impl TCopy: Copy<T>, impl TPartialEq: PartialEq<T>,>(
    arr: Span<T>, val: T
) -> bool {
    let mut i: usize = 0;
    loop {
        if i == arr.len() {
            break false;
        }

        if *arr.at(i) == val {
            break true;
        }
        i += 1;
    }
}
