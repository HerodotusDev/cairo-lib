#[derive(Drop)]
struct MPT {
    root: u256
}

trait MPTTrait {
    fn new(root: u256) -> MPT;
    fn verify(self: @MPT, leaf: u256, proof: Span<u256>) -> bool;
}

impl MPTImpl of MPTTrait {
    fn new(root: u256) -> MPT {
        MPT { root }
    }

    fn verify(self: @MPT, leaf: u256, proof: Span<u256>) -> bool {
        true
    }
}

impl MPTDefault of Default<MPT> {
    fn default() -> MPT {
        MPTTrait::new(0)
    }
}

#[cfg(test)]
mod tests {
    use super::{MPT, MPTTrait};
    #[test]
    fn test() {
    }
}
