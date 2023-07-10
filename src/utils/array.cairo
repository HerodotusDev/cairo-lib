use array::SpanTrait;

fn array_contains<T, impl TDrop: Drop<T>, impl TCopy: Copy<T>, impl TPartialEq: PartialEq<T>>(
    elem: T, arr: Span<T>
) -> bool {
    let arr_len = arr.len();
    let mut i = 0;
    let mut result = false;
    loop {
        if i == arr_len {
            break ();
        }
        if *arr.at(i) == elem {
            result = true;
            break ();
        }
        i += 1;
    };
    return result;
}
