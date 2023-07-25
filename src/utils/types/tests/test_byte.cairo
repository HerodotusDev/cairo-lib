use cairo_lib::utils::types::byte::{Byte, ByteTrait};

#[test]
#[available_gas(999999999)]
fn test_extract_nibbles() {
    let byte0: Byte = 0x00;
    assert(byte0.extract_nibbles() == (0x0, 0x0), 'extract_nibbles 0x00');

    let byte1: Byte = 0x4f;
    assert(byte1.extract_nibbles() == (0x4, 0xf), 'extract_nibbles 0x4f');

    let byte2: Byte = 0x5a;
    assert(byte2.extract_nibbles() == (0x5, 0xa), 'extract_nibbles 0x5a');

    let byte3: Byte = 0x6b;
    assert(byte3.extract_nibbles() == (0x6, 0xb), 'extract_nibbles 0x6b');

    let byte4: Byte = 0xff;
    assert(byte4.extract_nibbles() == (0xf, 0xf), 'extract_nibbles 0xff');
}
