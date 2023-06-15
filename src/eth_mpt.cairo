#[derive(Drop)]
struct MPT<T> {}

trait MPTTrait<T> {
    fn new() -> MPT<T>;
    fn verify(self: @MPT<T>, root: T, leaf: T, proof: Span<T>) -> bool;
}

impl MPTImpl<T, impl TDrop: Drop<T>> of MPTTrait<T> {
    fn new() -> MPT<T> {
        MPT {}
    }

    fn verify(self: @MPT<T>, root: T, leaf: T, proof: Span<T>) -> bool {
        true
    }
}

impl MPTDefault<T, impl TDrop: Drop<T>> of Default<MPT<T>> {
    fn default() -> MPT<T> {
        MPTTrait::new()
    }
}

#[cfg(test)]
mod tests {
    use super::{MPT, MPTTrait};
    #[test]
    fn test() {
    }
}
