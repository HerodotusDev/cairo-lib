use cairo_lib::hashing::hasher::Hasher;

struct MMR<T, H> {
    root: T,
    size: usize,
    hasher: H
}

#[derive(Drop)]
struct MMRProof<T> {
}

trait MMRTrait<T, H> {
    fn new(root: T, size: usize, hasher: H) -> MMR<T, H>;
    fn verify_proof(self: @MMR<T, H>, value: T, proof: MMRProof<T>) -> bool;
}

trait MMRProofTrait<T> {
    fn verify<H, impl HHasher: Hasher<T, T>, impl HDrop: Drop<H>>(self: MMRProof<T>, root: T, value: T, hasher: H) -> bool;
}

impl MMRProofImpl<T, impl TDrop: Drop<T>> of MMRProofTrait<T> {
    fn verify<H, impl HHasher: Hasher<T, T>, impl HDrop: Drop<H>>(self: MMRProof<T>, root: T, value: T, hasher: H) -> bool {
        //TODO
        true
    }
}

impl MMRImpl<T, impl TDrop: Drop<T>, impl TCopy: Copy<T>, H, impl HHasher: Hasher<T, T>> of MMRTrait<T, H> {
    fn new(root: T, size: usize, hasher: H) -> MMR<T, H> {
        MMR {
            root,
            size,
            hasher
        }
    }

    fn verify_proof(self: @MMR<T, H>, value: T, proof: MMRProof<T>) -> bool {
        proof.verify(*self.root, value, self.hasher)
    }
}
