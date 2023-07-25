use array::{Span, SpanTrait};

fn span_contains<
    T, 
    impl TDrop: Drop<T>,
    impl TCopy: Copy<T>,
    impl TPartialEq: PartialEq<T>,
>(arr: Span<T>, val: T) -> bool {
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
