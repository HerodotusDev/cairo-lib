use cairo_lib::utils::math::pow;

#[test]
#[available_gas(9999999)]
fn test_pow() {
    assert(pow(3_u8, 5_u8) == 243, 'u8');
    assert(pow(6_u16, 4_u16) == 1296, 'u16');
    assert(pow(11_u32, 5_u32) == 161051, 'u32');
    assert(pow(13_u64, 6_u64) == 4826809, 'u64');
    assert(pow(17_u128, 7_u128) == 410338673, 'u128');
    assert(pow(45_u256, 23_u256) == 105654455657631171893227100372314453125, 'u256');
}
