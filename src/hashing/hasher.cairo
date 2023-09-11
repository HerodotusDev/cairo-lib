// @notice A common interface for all hashers
trait Hasher<T, V> {
    // @notice Hashes a single value
    // @param a The value to hash
    // @return The hash of the value
    fn hash_single(a: T) -> V;

    // @notice Hashes two values
    // @param a The first value to hash
    // @param b The second value to hash
    // @return The hash of the two values
    fn hash_double(a: T, b: T) -> V;

    // @notice Hashes many values
    // @param input The values to hash
    // @return The hash of the value
    fn hash_many(input: Span<T>) -> V;
}
