use cairo_lib::utils::math::Exponentiation;

#[test]
#[available_gas(9999999)]
fn test_pow() {
    assert(3_u8.pow(5_u8) == 243, 'u8');
    assert(6_u16.pow(4_u16) == 1296, 'u16');
    assert(11_u32.pow(5_u32) == 161051, 'u32');
    assert(13_u64.pow(6_u64) == 4826809, 'u64');
    assert(17_u128.pow(7_u128) == 410338673, 'u128');
    assert(45_u256.pow(23_u256) == 105654455657631171893227100372314453125, 'u256');
}
