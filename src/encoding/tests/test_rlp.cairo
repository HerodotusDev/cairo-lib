use cairo_lib::encoding::rlp::{RLPItem, rlp_decode, rlp_decode_list_lazy};

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_string() {
    let mut i = 1;
    loop {
        if i == 0x80 {
            break ();
        }
        let mut arr = ArrayTrait::new();
        //let rev = reverse_endianness(i);
        arr.append(i);

        let (res, len) = rlp_decode(arr.span()).unwrap();
        assert(len == 1, 'Wrong len');
        assert(res == RLPItem::Bytes(arr.span()), 'Wrong value');

        i += 1;
    };
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_short_string() {
    let mut arr = array![0x39c034f66c805a9b, 0x1ea949fd892d8f8d, 0xbb9484cd74a43df3, 0xa8da3bf7];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0x9b - 0x80), 'Wrong len');

    let mut expected_res = array![
        0x8d39c034f66c805a, 0xf31ea949fd892d8f, 0xf7bb9484cd74a43d, 0xa8da3b
    ];
    let expected_item = RLPItem::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_long_string_len_1() {
    let mut arr = array![
        0xd459f97ea1f73cb8,
        0x103a7b34dc8d3888,
        0x6a98370c1d4385dd,
        0xa4b18da3ba18bd63,
        0x6e16ecc3de246f81,
        0x0479f7c4c4acb2b3,
        0xda53d0c6673c76ba,
        0xd97d198610ea
    ];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0xb8 - 0xb7) + 0x3c, 'Wrong len');

    let mut expected_res = array![
        0x3888d459f97ea1f7,
        0x85dd103a7b34dc8d,
        0xbd636a98370c1d43,
        0x6f81a4b18da3ba18,
        0xb2b36e16ecc3de24,
        0x76ba0479f7c4c4ac,
        0x10eada53d0c6673c,
        0xd97d1986
    ];
    let expected_item = RLPItem::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_long_string_len_2() {
    let mut arr = array![
        0x59f97ea1f70201b9,
        0x3a7b34dc8d3888d4,
        0x98370c1d4385dd10,
        0xb18da3ba18bd636a,
        0x16ecc3de246f81a4,
        0x79f7c4c4acb2b36e,
        0x53d0c6673c76ba04,
        0x33d97d198610eada,
        0x6743897634694758,
        0x8967953487764593,
        0x3463437986433634,
        0x6459836758496378,
        0x4369695874933756,
        0x8963459867483967,
        0x4056046337946745,
        0x0365406808436839,
        0x8736956448938046,
        0x9534897673568439,
        0x3498609340657386,
        0x5908368056048356,
        0x5940680683064568,
        0x4830680384654068,
        0x9568574983460365,
        0x8769748376346879,
        0x4798637584635943,
        0x4365879473863456,
        0x5786347996346798,
        0x8956873469574893,
        0x7953564973685734,
        0x4738799634679543,
        0x4553638967946353,
        0x6868876897887968,
        0x6087997668
    ];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0xb9 - 0xb7) + 0x0102, 'Wrong len');

    let mut expected_res = array![
        0x3888d459f97ea1f7,
        0x85dd103a7b34dc8d,
        0xbd636a98370c1d43,
        0x6f81a4b18da3ba18,
        0xb2b36e16ecc3de24,
        0x76ba0479f7c4c4ac,
        0x10eada53d0c6673c,
        0x69475833d97d1986,
        0x7645936743897634,
        0x4336348967953487,
        0x4963783463437986,
        0x9337566459836758,
        0x4839674369695874,
        0x9467458963459867,
        0x4368394056046337,
        0x9380460365406808,
        0x5684398736956448,
        0x6573869534897673,
        0x0483563498609340,
        0x0645685908368056,
        0x6540685940680683,
        0x4603654830680384,
        0x3468799568574983,
        0x6359438769748376,
        0x8634564798637584,
        0x3467984365879473,
        0x5748935786347996,
        0x6857348956873469,
        0x6795437953564973,
        0x9463534738799634,
        0x8879684553638967,
        0x9976686868876897,
        0x6087
    ];
    let expected_item = RLPItem::Bytes(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_short_list() {
    let mut arr = array![0x45834289353583c9, 0x9238];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0xc9 - 0xc0), 'Wrong len');

    let mut expected_res = array![
        array![0x893535].span(), array![0x42].span(), array![0x923845].span()
    ];
    let expected_item = RLPItem::List(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_lazy_decode_short_list() {
    let mut arr = array![0x45834289353583c9, 0x9238];

    let res = rlp_decode_list_lazy(arr.span(), array![].span()).unwrap();
    assert(res.is_empty(), 'Wrong value indexes: empty');

    let res = rlp_decode_list_lazy(arr.span(), array![1].span()).unwrap();
    let expected_res = array![
        array![0x42].span()
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 1');
    
    let res = rlp_decode_list_lazy(arr.span(), array![0, 1, 2].span()).unwrap();
    let mut expected_res = array![
        array![0x893535].span(), array![0x42].span(), array![0x923845].span()
    ].span();
    assert(res == expected_res, 'Wrong value: indexes: 0, 1, 2');

    let res = rlp_decode_list_lazy(arr.span(), array![0, 2].span()).unwrap();
    let mut expected_res = array![
        array![0x893535].span(), array![0x923845].span()
    ].span();
    assert(res == expected_res, 'Wrong value: indexes: 0, 2');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_long_list() {
    let mut arr = array![
        0x09cf7077a01102f9,
        0xa962df351b7a06b5,
        0xadecaece75818924,
        0x0c4044a8b4cd681f,
        0x85a31ea0f44ac173,
        0x045c6d4661b25ad0,
        0x1a9fc1344568fe87,
        0x35361adc184b5c4b,
        0x4c2ca0b471500260,
        0x1846d1d34035ce04,
        0x8366e5a5533c3072,
        0x0c80a8368d4f30c1,
        0xa9a0eecd3ffaf56a,
        0xc4d37d4bc58d77dc,
        0xb0fe61d139e72282,
        0x3717d5dcb2ceeec0,
        0xa05138a6378e5bf0,
        0xdd62df56554d5fa9,
        0x9b56ae97049962c2,
        0x9307207bdafd8ecd,
        0xd71897db4cded3f8,
        0x2238146d06d439a0,
        0x74a843e9c94aaf6e,
        0xb91dd8b05fc2a9a9,
        0x03e2b336138c1d86,
        0x6ab4637ccc7aa04c,
        0x25a141a0c9b318a4,
        0x7a396b316173cb6b,
        0x13bb1b4967885ada,
        0x25818a3515a03001,
        0xc736fe137193c42e,
        0x3497a1fb11b74680,
        0x5f78007a1829bb91,
        0xd3429168a0ae52f8,
        0xdfce8b1ca7faab16,
        0x254e10b2db1d2049,
        0x1f2256e8c490dc0a,
        0x5036dca058964a53,
        0xa714a3a8fd342599,
        0xb59dc7a83baeb0db,
        0xc060242ace690c55,
        0xb020a0a3c1c4ad07,
        0xe19e05b055663b68,
        0xc1cb6b504b4ed003,
        0x11b1dab792630039,
        0x8ea0e7420366c278,
        0xd91c0f63fb45ebed,
        0xcb17225718eb3697,
        0x03e21bb715f3d5c6,
        0xa014269bd9e83cb0,
        0x6f985af63da32379,
        0x69b9c2e4e6f9e7d5,
        0x3999be4e94086b73,
        0xf309e62f6114864a,
        0x71201ad0d73465a0,
        0xce46b9552afba44a,
        0xa22aadff2d22c364,
        0xb12ac97334928ad1,
        0xb8fe8bc2f9bfa0fd,
        0xb0c3c818b6a92dbf,
        0x4714bdc0b10ce86f,
        0xe229ff6121c4f738,
        0x3c6961147fa02f50,
        0x5ea3bb1b02a54e70,
        0x8f459e43f602c572,
        0x8fea4837d02e2498,
        0x805fb3e2
    ];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0xf9 - 0xf7) + 0x0211, 'Wrong len');

    let mut expected_res = array![
        array![0x1b7a06b509cf7077, 0x75818924a962df35, 0xb4cd681fadecaece, 0xf44ac1730c4044a8]
            .span(),
        array![0x4661b25ad085a31e, 0x344568fe87045c6d, 0xdc184b5c4b1a9fc1, 0xb47150026035361a]
            .span(),
        array![0xd1d34035ce044c2c, 0xe5a5533c30721846, 0xa8368d4f30c18366, 0xeecd3ffaf56a0c80]
            .span(),
        array![0xd37d4bc58d77dca9, 0xfe61d139e72282c4, 0x17d5dcb2ceeec0b0, 0x5138a6378e5bf037]
            .span(),
        array![0xdd62df56554d5fa9, 0x9b56ae97049962c2, 0x9307207bdafd8ecd, 0xd71897db4cded3f8]
            .span(),
        array![ // 5
        0x6e2238146d06d439, 0xa974a843e9c94aaf, 0x86b91dd8b05fc2a9, 0x4c03e2b336138c1d]
            .span(),
        array![0x18a46ab4637ccc7a, 0xcb6b25a141a0c9b3, 0x5ada7a396b316173, 0x300113bb1b496788]
            .span(),
        array![0x93c42e25818a3515, 0xb74680c736fe1371, 0x29bb913497a1fb11, 0xae52f85f78007a18]
            .span(),
        array![0xa7faab16d3429168, 0xdb1d2049dfce8b1c, 0xc490dc0a254e10b2, 0x58964a531f2256e8]
            .span(),
        array![0xa8fd3425995036dc, 0xa83baeb0dba714a3, 0x2ace690c55b59dc7, 0xa3c1c4ad07c06024]
            .span(),
        array![0x05b055663b68b020, 0x6b504b4ed003e19e, 0xdab792630039c1cb, 0xe7420366c27811b1]
            .span(),
        array![0x1c0f63fb45ebed8e, 0x17225718eb3697d9, 0xe21bb715f3d5c6cb, 0x14269bd9e83cb003]
            .span(),
        array![0x6f985af63da32379, 0x69b9c2e4e6f9e7d5, 0x3999be4e94086b73, 0xf309e62f6114864a]
            .span(),
        array![0x4a71201ad0d73465, 0x64ce46b9552afba4, 0xd1a22aadff2d22c3, 0xfdb12ac97334928a]
            .span(),
        array![0x2dbfb8fe8bc2f9bf, 0xe86fb0c3c818b6a9, 0xf7384714bdc0b10c, 0x2f50e229ff6121c4]
            .span(),
        array![0xa54e703c6961147f, 0x02c5725ea3bb1b02, 0x2e24988f459e43f6, 0x5fb3e28fea4837d0]
            .span(),
        array![].span()
    ];
    let expected_item = RLPItem::List(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_lazy_decode_long_list() {
    let mut arr = array![
        0x09cf7077a01102f9,
        0xa962df351b7a06b5,
        0xadecaece75818924,
        0x0c4044a8b4cd681f,
        0x85a31ea0f44ac173,
        0x045c6d4661b25ad0,
        0x1a9fc1344568fe87,
        0x35361adc184b5c4b,
        0x4c2ca0b471500260,
        0x1846d1d34035ce04,
        0x8366e5a5533c3072,
        0x0c80a8368d4f30c1,
        0xa9a0eecd3ffaf56a,
        0xc4d37d4bc58d77dc,
        0xb0fe61d139e72282,
        0x3717d5dcb2ceeec0,
        0xa05138a6378e5bf0,
        0xdd62df56554d5fa9,
        0x9b56ae97049962c2,
        0x9307207bdafd8ecd,
        0xd71897db4cded3f8,
        0x2238146d06d439a0,
        0x74a843e9c94aaf6e,
        0xb91dd8b05fc2a9a9,
        0x03e2b336138c1d86,
        0x6ab4637ccc7aa04c,
        0x25a141a0c9b318a4,
        0x7a396b316173cb6b,
        0x13bb1b4967885ada,
        0x25818a3515a03001,
        0xc736fe137193c42e,
        0x3497a1fb11b74680,
        0x5f78007a1829bb91,
        0xd3429168a0ae52f8,
        0xdfce8b1ca7faab16,
        0x254e10b2db1d2049,
        0x1f2256e8c490dc0a,
        0x5036dca058964a53,
        0xa714a3a8fd342599,
        0xb59dc7a83baeb0db,
        0xc060242ace690c55,
        0xb020a0a3c1c4ad07,
        0xe19e05b055663b68,
        0xc1cb6b504b4ed003,
        0x11b1dab792630039,
        0x8ea0e7420366c278,
        0xd91c0f63fb45ebed,
        0xcb17225718eb3697,
        0x03e21bb715f3d5c6,
        0xa014269bd9e83cb0,
        0x6f985af63da32379,
        0x69b9c2e4e6f9e7d5,
        0x3999be4e94086b73,
        0xf309e62f6114864a,
        0x71201ad0d73465a0,
        0xce46b9552afba44a,
        0xa22aadff2d22c364,
        0xb12ac97334928ad1,
        0xb8fe8bc2f9bfa0fd,
        0xb0c3c818b6a92dbf,
        0x4714bdc0b10ce86f,
        0xe229ff6121c4f738,
        0x3c6961147fa02f50,
        0x5ea3bb1b02a54e70,
        0x8f459e43f602c572,
        0x8fea4837d02e2498,
        0x805fb3e2
    ];

    let mut expected_res_full = array![
        array![0x1b7a06b509cf7077, 0x75818924a962df35, 0xb4cd681fadecaece, 0xf44ac1730c4044a8]
            .span(),
        array![0x4661b25ad085a31e, 0x344568fe87045c6d, 0xdc184b5c4b1a9fc1, 0xb47150026035361a]
            .span(),
        array![0xd1d34035ce044c2c, 0xe5a5533c30721846, 0xa8368d4f30c18366, 0xeecd3ffaf56a0c80]
            .span(),
        array![0xd37d4bc58d77dca9, 0xfe61d139e72282c4, 0x17d5dcb2ceeec0b0, 0x5138a6378e5bf037]
            .span(),
        array![0xdd62df56554d5fa9, 0x9b56ae97049962c2, 0x9307207bdafd8ecd, 0xd71897db4cded3f8]
            .span(),
        array![ // 5
        0x6e2238146d06d439, 0xa974a843e9c94aaf, 0x86b91dd8b05fc2a9, 0x4c03e2b336138c1d]
            .span(),
        array![0x18a46ab4637ccc7a, 0xcb6b25a141a0c9b3, 0x5ada7a396b316173, 0x300113bb1b496788]
            .span(),
        array![0x93c42e25818a3515, 0xb74680c736fe1371, 0x29bb913497a1fb11, 0xae52f85f78007a18]
            .span(),
        array![0xa7faab16d3429168, 0xdb1d2049dfce8b1c, 0xc490dc0a254e10b2, 0x58964a531f2256e8]
            .span(),
        array![0xa8fd3425995036dc, 0xa83baeb0dba714a3, 0x2ace690c55b59dc7, 0xa3c1c4ad07c06024]
            .span(),
        array![0x05b055663b68b020, 0x6b504b4ed003e19e, 0xdab792630039c1cb, 0xe7420366c27811b1]
            .span(),
        array![0x1c0f63fb45ebed8e, 0x17225718eb3697d9, 0xe21bb715f3d5c6cb, 0x14269bd9e83cb003]
            .span(),
        array![0x6f985af63da32379, 0x69b9c2e4e6f9e7d5, 0x3999be4e94086b73, 0xf309e62f6114864a]
            .span(),
        array![0x4a71201ad0d73465, 0x64ce46b9552afba4, 0xd1a22aadff2d22c3, 0xfdb12ac97334928a]
            .span(),
        array![0x2dbfb8fe8bc2f9bf, 0xe86fb0c3c818b6a9, 0xf7384714bdc0b10c, 0x2f50e229ff6121c4]
            .span(),
        array![0xa54e703c6961147f, 0x02c5725ea3bb1b02, 0x2e24988f459e43f6, 0x5fb3e28fea4837d0]
            .span(),
        array![].span()
    ];

    let res = rlp_decode_list_lazy(arr.span(), array![].span()).unwrap();
    assert(res.is_empty(), 'Wrong value indexes: empty');

    let res = rlp_decode_list_lazy(arr.span(), array![0].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(0)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 0');

    let res = rlp_decode_list_lazy(arr.span(), array![1].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(1)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 1');

    let res = rlp_decode_list_lazy(arr.span(), array![0xa].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(0xa)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 10');

    let res = rlp_decode_list_lazy(arr.span(), array![0x5, 0x9, 0xf].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(0x5), *expected_res_full.at(0x9), *expected_res_full.at(0xf)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 5, 9, 15');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_decode_list_long_string() {
    let arr = array![
        0x7235e356aca05bf8,
        0x7f0b03476f57b94f,
        0x4760f75aaf1d2720,
        0xa9c2173ae53aab1f,
        0xf338d438b8ed276f,
        0x27777eada3968dad,
        0x53189e661865fe38,
        0xc101f7b5d6dffd52,
        0x65454695474abcbb,
        0x4567644756674547,
        0x5663776535476567,
        0xfa77645733,
    ];

    let (res, len) = rlp_decode(arr.span()).unwrap();
    assert(len == 1 + (0xf8 - 0xf7) + 0x5b, 'Wrong len');

    let expected_res = array![
        array![
            0x57b94f7235e356ac,
            0x1d27207f0b03476f,
            0x3aab1f4760f75aaf,
            0xed276fa9c2173ae5,
        ].span(),
        array![
            0xada3968dadf338d4,
            0x661865fe3827777e,
            0xb5d6dffd5253189e,
            0x95474abcbbc101f7,
            0x4756674547654546,
            0x6535476567456764,
            0xfa77645733566377,
        ].span(),
    ];
    let expected_item = RLPItem::List(expected_res.span());
    assert(res == expected_item, 'Wrong value');
}

#[test]
#[available_gas(99999999)]
fn test_rlp_lazy_decode_list_long_string() {
    let arr = array![
        0x7235e356aca05bf8,
        0x7f0b03476f57b94f,
        0x4760f75aaf1d2720,
        0xa9c2173ae53aab1f,
        0xf338d438b8ed276f,
        0x27777eada3968dad,
        0x53189e661865fe38,
        0xc101f7b5d6dffd52,
        0x65454695474abcbb,
        0x4567644756674547,
        0x5663776535476567,
        0xfa77645733,
    ];

    let expected_res_full = array![
        array![
            0x57b94f7235e356ac,
            0x1d27207f0b03476f,
            0x3aab1f4760f75aaf,
            0xed276fa9c2173ae5,
        ].span(),
        array![
            0xada3968dadf338d4,
            0x661865fe3827777e,
            0xb5d6dffd5253189e,
            0x95474abcbbc101f7,
            0x4756674547654546,
            0x6535476567456764,
            0xfa77645733566377,
        ].span(),
    ];

    let res = rlp_decode_list_lazy(arr.span(), array![].span()).unwrap();
    assert(res.is_empty(), 'Wrong value indexes: empty');

    let res = rlp_decode_list_lazy(arr.span(), array![0].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(0)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 0');

    let res = rlp_decode_list_lazy(arr.span(), array![1].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(1)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 1');

    let res = rlp_decode_list_lazy(arr.span(), array![0, 1].span()).unwrap();
    let expected_res = array![
        *expected_res_full.at(0), *expected_res_full.at(1)
    ].span();
    assert(res == expected_res, 'Wrong value indexes: 0, 1');
}
