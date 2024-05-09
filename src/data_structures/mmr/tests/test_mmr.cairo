use cairo_lib::data_structures::mmr::mmr::{MMR, MMRTrait};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::data_structures::mmr::utils::mmr_size_to_leaf_count;
use debug::PrintTrait;
use cairo_lib::encoding::rlp::{RLPItem, rlp_decode_list_lazy};
    use cairo_lib::utils::types::words64::{reverse_endianness_u64, bytes_used_u64, Words64};
use cairo_lib::hashing::poseidon::{hash_words64};
const BLOCK_NUMBER_OFFSET_IN_HEADER_RLP: usize = 8;
const TIMESTAMP_OFFSET_IN_HEADER_RLP: usize = 11;
use cairo_lib::data_structures::mmr::proof::Proof;
use cairo_lib::data_structures::mmr::peaks::Peaks;

fn helper_test_get_elements() -> Span<felt252> {
    let elem1 = PoseidonHasher::hash_single(1);
    let elem2 = PoseidonHasher::hash_single(2);
    let elem3 = PoseidonHasher::hash_double(elem1, elem2);
    let elem4 = PoseidonHasher::hash_single(4);
    let elem5 = PoseidonHasher::hash_single(5);
    let elem6 = PoseidonHasher::hash_double(elem4, elem5);
    let elem7 = PoseidonHasher::hash_double(elem3, elem6);
    let elem8 = PoseidonHasher::hash_single(8);

    let arr = array![elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8];
    arr.span()
}

#[test]
#[available_gas(99999999)]
fn test_append_initial() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();

    let peaks = array![].span();
    let (new_root, new_peaks) = mmr.append(*elems.at(0), peaks).unwrap();

    let expected_root = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(mmr.last_pos == 1, 'Wrong last_pos');
    assert(mmr.root == expected_root, 'Wrong updated root');
    assert(new_root == expected_root, 'Wrong returned root');

    assert(new_peaks == array![*elems.at(0)].span(), 'Wrong new_peaks');
}


#[test]
#[available_gas(99999999)]
fn test_zjebany() {
    let mut mmr: MMR = Default::default();
    let (_, peaks) = mmr.append(1715180160, array![].span()).unwrap();
    mmr.append(1715180172, peaks).unwrap();
    mmr.root.print();
    assert(mmr.root == 0x32f5a2949cac3d06e854701c5a2a00ed51c0475a31c1bc17cc6d3ec46425e9, 'aaa');
}

fn extract_header_block_number_and_timestamp(header: Words64) -> (u256, u256) {
    let (decoded_rlp, _) = rlp_decode_list_lazy(
        header,
        array![BLOCK_NUMBER_OFFSET_IN_HEADER_RLP, TIMESTAMP_OFFSET_IN_HEADER_RLP].span()
    )
        .unwrap();
    let ((block_number, block_number_byte_len), (timestamp, timestamp_byte_len)) =
        match decoded_rlp {
        RLPItem::Bytes(_) => panic_with_felt252('Invalid header rlp'),
        RLPItem::List(l) => { (*l.at(0), *l.at(1)) },
    };
    let block0 = *block_number.at(0);
    let time0 = *timestamp.at(0);
    'block0'.print();
    block0.print();
    'time0'.print();
    time0.print();
    (
        reverse_endianness_u64(block0, Option::Some(block_number_byte_len))
            .into(),
        reverse_endianness_u64(time0, Option::Some(timestamp_byte_len)).into()
    )
}

#[derive(Drop)]
struct OriginElement {
    tree_id: usize,
    last_pos: usize,
    leaf_idx: usize,
    leaf_value: felt252,
    inclusion_proof: Proof,
    peaks: Peaks,
    header: Words64
}

#[test]
#[available_gas(99999999)]
fn test_zjebany_maciek() {
    //? @mikjakbiak
    
    let xd: Span<felt252> = array![].span();
    let mapper_id: usize = 0;
    let mapper_peaks: Peaks = array![].span();
    let xd1 = array![
        0x77fcd482169b065b12b4d85eae49de97c370364d07fa5cce76ee6580aed35a9,
        0x4550ede153ac0774abeb2655900073bc403801b45d79c6fd3687f4bf44b432,
        0x12727419baf4e9a378f9608516db2a3758aaf58cee0c9e8e4e33652a5d47c0b,
        0x58a3db2674a8e4439b0312d1c050e11a7641beb7daf2f5ae3f758df600dde71,
        0x6e65b643b3cc3298596ae5e4ca8bc539ab59f3c9e3e4b9d072f230dce0ae632,
        0x6f8c8e930d19849e32d964f9f84b43070c4ba1f825c20d5e473d3b59b9bde98,
        0x4f86e8c42faecc0259b0b6af90166c7c03abb9f43a4a7bce61907af7b6e0238
    ].span();
    let xd2 = array![        
        0xe8b262aba04d02f9,
        0xe92b43b7269adf2c,
        0x3219c99e0e62e108,
        0xdbd718a65e62ee2c,
        0x4dcc1da0a7025592,
        0xb585ab7a5dc7dee8,
        0x4512d31ad4ccb667,
        0x42a1f013748a941b,
        0x76e2944793d440fd,
        0xb392877a528a37bc,
        0x3d26535e5bcacd53,
        0xad8845282ba09efb,
        0xadd0ff882e102608,
        0x9377fd4a5e390028,
        0xa12a5b983f7494f6,
        0xbb0912aa0f040a8,
        0x908c7c096ebb3e55,
        0xaf8972d156174118,
        0x2052c8ee7d4dfcdd,
        0x30074ba0dd8f0136,
        0x29fbe705757dfc39,
        0xd5bf3e2a18cd7521,
        0xa4236967d566a919,
        0x1b96afce6f5b3,
        0x83c162e3cf68b4e0,
        0x603d92a232041c65,
        0x4205289502249be4,
        0xa953375766002824,
        0x27022be1a1d03a26,
        0x865184121ec29456,
        0x4a736a83a546402b,
        0xa4e6d4212124090,
        0x1bb1bcd95a562041,
        0xc2880c131ac690c6,
        0x476d4591ed464a24,
        0x1152501072246a61,
        0x1feac0a84a852d4,
        0xca4d0015481089ac,
        0x48845640f0680802,
        0x623498201b6e6803,
        0x5690f81f6811e4e6,
        0x10fa5240ab1144a4,
        0xa5908e488386b004,
        0x289c44caa01415f,
        0x212636b0ea269a42,
        0xb4e051a1cb078fb,
        0xc20040d091026f98,
        0x1b42e2a412c0c6a8,
        0xa060389a66bb9413,
        0x48eb16f89694bb01,
        0x46666b03c62101c0,
        0x6ced8022d21396c2,
        0x528930242007d84a,
        0x2612953852d414a9,
        0xde22b54e141e508b,
        0x2432452d008887e,
        0xc901846371598380,
        0x848e9a1c018480c3,
        0x8987a08080923b66,
        0xb70ac31dd828882,
        0xbe0d1998c187602b,
        0x84e021ad60db368a,
        0x886e92cd1e5cf7,
        0x8500000000000000,
        0xe271a0cd0fefcb08,
        0xb13f931db22a2c83,
        0x23f9cf41e107c409,
        0xccfd4c39f2afd5a7,
        0xc837cf063a840dc,
        0xa000009805840000,
        0xcb1b14988ae5328c,
        0xa2ab435d3495032,
        0x38e31c987d75b08b,
        0xbba3bdee6b8da852
    ].span();
    let xd3 = array![
        0x1a44f2fefdf5db18d799348b0815c807228bd3ad100fb4e08877b03aa0bd05d,
        0x67bc1db51abe9fca4628aa545314055d19f74c3abc87676c93a61169e2a9643,
        0x512608506ff6d4dc57496f2e1a88eaac50645b156c3d3bebeec53ce35122966
    ].span();
    let xd4 = array![
        0x77fcd482169b065b12b4d85eae49de97c370364d07fa5cce76ee6580aed35a9,
        0x4550ede153ac0774abeb2655900073bc403801b45d79c6fd3687f4bf44b432,
        0x12727419baf4e9a378f9608516db2a3758aaf58cee0c9e8e4e33652a5d47c0b,
        0x58a3db2674a8e4439b0312d1c050e11a7641beb7daf2f5ae3f758df600dde71,
        0x6e65b643b3cc3298596ae5e4ca8bc539ab59f3c9e3e4b9d072f230dce0ae632,
        0x6f8c8e930d19849e32d964f9f84b43070c4ba1f825c20d5e473d3b59b9bde98,
        0x4f86e8c42faecc0259b0b6af90166c7c03abb9f43a4a7bce61907af7b6e0238
    ].span();
    let xd5 = array![
        0x9eed004ca06502f9,
        0x5b75774186ed10d9,
        0xbb4649fca41e5424,
        0x639216cba5fe86e1,
        0x4dcc1da0c0429a8a,
        0xb585ab7a5dc7dee8,
        0x4512d31ad4ccb667,
        0x42a1f013748a941b,
        0x5e45944793d440fd,
        0xf4ce6cbc6984a15a,
        0xa387c56656649495,
        0xee3d20a487a01ba7,
        0xc6a11a35aa7e128,
        0x1c0f7ee184ee3751,
        0xfcbc2de8a0d63296,
        0x2105031ca0c9d886,
        0xdb89f2446e32c88,
        0x1d42cc502b23ad8,
        0x2290f6c9607e74a1,
        0xf02a6da0e0e86af5,
        0x3e1d9101e196684e,
        0x3800a9e1172b0ba5,
        0x45f1c0b883efde37,
        0x1b9f31cb75b3a,
        0x84543564a20966a,
        0x405128121244181d,
        0x7010880205182360,
        0x804288420a012813,
        0x80e2bb029102802,
        0xc454251448024132,
        0x8e222021501242c,
        0x222368c4291203d3,
        0x53908e5843c22580,
        0xc128401ab26454,
        0x143061015527146,
        0xb06a4a54243e1042,
        0x618f24a240801580,
        0xc84900214288428a,
        0x62005a60dc001a21,
        0x234500458a70892,
        0x3ae53619214000b6,
        0x280ba6488412165,
        0x60c4280a2072c12,
        0xe88156b5c0210136,
        0xc00036a50a28098b,
        0x641e20a862425c40,
        0x1002403c95454278,
        0x78534b4402498d89,
        0x804ad0d13e101483,
        0xc0243d8b180fa00,
        0x5205b8180a08061,
        0xe66894200011c38e,
        0x1020023609043f12,
        0x320a9e3202a5e0e9,
        0x542b9c0b6318496b,
        0xe4655898408a68,
        0xc901846471598380,
        0x668435e0a28380c3,
        0xd0183d8998c923b,
        0x678868746567840f,
        0x85392e31322e316f,
        0x91b0a078756e696c,
        0x3057fafd29be6dd7,
        0x61ec76ea04a565a9,
        0x7af26fbd94983dff,
        0x88cec6141302da,
        0x8500000000000000,
        0x13cea01fb8761009,
        0xc5a46e64904fd16d,
        0xd26ea090d7ef9b1e,
        0x45f94b5db0cb4da5,
        0xa83a9b0ed98a798,
        0xa000009e05840000,
        0x7037c4aa85fd018f,
        0x8a792e1cbca49248,
        0xdd1597c777d066ed,
        0x7aea291a6657d84c
    ].span();
    let oe1 = OriginElement {
        tree_id: 1,
        last_pos: 21291,
        leaf_idx: 21291,
        leaf_value: 0x4f86e8c42faecc0259b0b6af90166c7c03abb9f43a4a7bce61907af7b6e0238,
        inclusion_proof: xd,
        peaks: xd1,
        header: xd2
    };
    let oe2 = OriginElement {
        tree_id: 1,
        last_pos: 21291,
        leaf_idx: 21287,
        leaf_value: 0x61fb030eff091579b9f702308ceab97611a575de15ceaad856a1efebd06bd82,
        inclusion_proof: xd3,
        peaks: xd4,
        header: xd5
    };
    let oes: Array<OriginElement> = array![
        oe1,
        oe2
    ];
    let origin_elements = oes.span();

    let mut mapper_mmr: MMR = Default::default();

    let len = origin_elements.len();
    let mut idx = 0;
    let mut last_timestamp = 0; // Local to this batch
    let mut peaks = mapper_peaks;

    loop {
        if idx == len {
            break ();
        }

        // 1. Verify that the block number is correct (i.e., matching with the expected block)
        let origin_element: @OriginElement = origin_elements.at(idx);
        let (origin_element_block_number, origin_element_timestamp) =
            extract_header_block_number_and_timestamp(
            *origin_element.header
        );

        // 2. Verify that the header rlp is correct (i.e., matching with the leaf value)
        let current_hash = hash_words64(*origin_element.header);
        assert(current_hash == *origin_element.leaf_value.into(), 'Invalid header rlp');

        // Add the block timestamp to the mapper MMR so we can binary search it later
        'timestamp: '.print();
        let asfelt: felt252 = origin_element_timestamp.try_into().unwrap();
        
        asfelt.print();
        let (_, p) = mapper_mmr
            .append(asfelt, peaks)
            .unwrap();
        peaks = p;


        // Update storage to the last timestamp of the batch
        if idx == len - 1 {
            last_timestamp = origin_element_timestamp;
        }

        idx += 1;
    };

    'root: '.print();
    mapper_mmr.root.print();

    assert(mapper_mmr.root == 0x32f5a2949cac3d06e854701c5a2a00ed51c0475a31c1bc17cc6d3ec46425e9, 'bbb');

    // 0x670401c3a2441614da21ef2f15e9bb6c36c3dd585fff8360875b2122c9290b5
}

#[test]
#[available_gas(99999999)]
fn test_append_1() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    assert(mmr.last_pos == 3, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_2() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(
        4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3))
    );
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    assert(mmr.last_pos == 4, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_3() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(
        4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3))
    );
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    let (mmr_root_4, mmr_peaks_4) = mmr.append(*elems.at(4), mmr_peaks_3).unwrap();

    let expected_peaks_4 = array![*elems.at(6)].span();
    let expected_root_4 = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(expected_peaks_4 == mmr_peaks_4, 'Wrong peaks after 4 appends');
    assert(mmr.root == expected_root_4, 'Wrong updated root after 4 a.');
    assert(mmr_root_4 == expected_root_4, 'Wrong reeturned root after 4 a.');

    assert(mmr.last_pos == 7, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_4() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let mmr_peaks_0 = array![].span();

    let (mmr_root_1, mmr_peaks_1) = mmr.append(*elems.at(0), mmr_peaks_0).unwrap();

    let expected_peaks_1 = array![*elems.at(0)].span();
    let expected_root_1 = PoseidonHasher::hash_double(1, *elems.at(0));
    assert(expected_peaks_1 == mmr_peaks_1, 'Wrong peaks after 1 append');
    assert(mmr.root == expected_root_1, 'Wrong updated root after 2 a.');
    assert(mmr_root_1 == expected_root_1, 'Wrong returned root after 1 a.');

    let (mmr_root_2, mmr_peaks_2) = mmr.append(*elems.at(1), mmr_peaks_1).unwrap();

    let expected_peaks_2 = array![*elems.at(2)].span();
    let expected_root_2 = PoseidonHasher::hash_double(3, *elems.at(2));
    assert(expected_peaks_2 == mmr_peaks_2, 'Wrong peaks after 2 appends');
    assert(mmr.root == expected_root_2, 'Wrong updated root after 2 a.');
    assert(mmr_root_2 == expected_root_2, 'Wrong reeturned root after 2 a.');

    let (mmr_root_3, mmr_peaks_3) = mmr.append(*elems.at(3), mmr_peaks_2).unwrap();

    let expected_peaks_3 = array![*elems.at(2), *elems.at(3)].span();
    let expected_root_3 = PoseidonHasher::hash_double(
        4, PoseidonHasher::hash_double(*elems.at(2), *elems.at(3))
    );
    assert(expected_peaks_3 == mmr_peaks_3, 'Wrong peaks after 3 appends');
    assert(mmr.root == expected_root_3, 'Wrong updated root after 3 a.');
    assert(mmr_root_3 == expected_root_3, 'Wrong reeturned root after 3 a.');

    let (mmr_root_4, mmr_peaks_4) = mmr.append(*elems.at(4), mmr_peaks_3).unwrap();

    let expected_peaks_4 = array![*elems.at(6)].span();
    let expected_root_4 = PoseidonHasher::hash_double(7, *elems.at(6));
    assert(expected_peaks_4 == mmr_peaks_4, 'Wrong peaks after 4 appends');
    assert(mmr.root == expected_root_4, 'Wrong updated root after 4 a.');
    assert(mmr_root_4 == expected_root_4, 'Wrong reeturned root after 4 a.');

    let (mmr_root_5, mmr_peaks_5) = mmr.append(*elems.at(7), mmr_peaks_4).unwrap();

    let expected_peaks_5 = array![*elems.at(6), *elems.at(7)].span();
    let expected_root_5 = PoseidonHasher::hash_double(
        8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
    );
    assert(expected_peaks_5 == mmr_peaks_5, 'Wrong peaks after 5 appends');
    assert(mmr.root == expected_root_5, 'Wrong updated root after 5 a.');
    assert(mmr_root_5 == expected_root_5, 'Wrong reeturned root after 5 a.');

    assert(mmr.last_pos == 8, 'Wrong last_pos');
}

#[test]
#[available_gas(99999999)]
fn test_append_wrong_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr: MMR = Default::default();
    let peaks = array![].span();

    let (_, peaks) = mmr.append(*elems.at(0), peaks).unwrap();

    let (_, peaks) = mmr.append(*elems.at(1), peaks).unwrap();

    let (_, peaks) = mmr.append(*elems.at(3), peaks).unwrap();

    assert(peaks == array![*elems.at(2), *elems.at(3)].span(), 'Wrong peaks returned by append');

    let wrong_peaks = array![*elems.at(2), *elems.at(4)].span();
    let res = mmr.append(*elems.at(4), wrong_peaks);

    assert(res.is_err(), 'Appnd accepted with wrong peaks');
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_all_left() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(1), *elems.at(5)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(mmr.verify_proof(1, *elems.at(0), peaks, proof).unwrap(), 'Invalid proof all left')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_all_right() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(3), *elems.at(2)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(mmr.verify_proof(5, *elems.at(4), peaks, proof).unwrap(), 'Invalid proof all right')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_left_right() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(0), *elems.at(5)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(
        mmr.verify_proof(2, *elems.at(1), peaks, proof).unwrap(), 'Valid invalid proof left right'
    )
}

#[test]
#[available_gas(99999999)]
fn test_verify_invalid_proof() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(2), *elems.at(2)].span();
    let peaks = array![*elems.at(6), *elems.at(7)].span();

    assert(!mmr.verify_proof(2, *elems.at(1), peaks, proof).unwrap(), 'Invalid proof left right')
}

#[test]
#[available_gas(99999999)]
fn test_verify_proof_invalid_peaks() {
    let elems = helper_test_get_elements();
    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(
            8, PoseidonHasher::hash_double(*elems.at(6), *elems.at(7))
        ),
        last_pos: 8
    );

    let proof = array![*elems.at(0), *elems.at(5)].span();
    let peaks = array![*elems.at(1), *elems.at(5)].span();

    assert(mmr.verify_proof(2, *elems.at(1), peaks, proof).is_err(), 'Proof wrong peaks')
}

#[test]
#[available_gas(99999999)]
fn test_attack_forge_peaks() {
    let elems = helper_test_get_elements();
    let mut mmr_real: MMR = MMRTrait::new(
        0x21aea73dea77022a4882e1f656b76c9195161ed1cff2b065a74d7246b02d5d6, 0x8
    );
    let mut mmr_fake: MMR = MMRTrait::new(
        0x21aea73dea77022a4882e1f656b76c9195161ed1cff2b065a74d7246b02d5d6, 0x8
    );

    // add the next element normally to mmr_real and get the root;
    let peaks_real = array![*elems.at(6), *elems.at(7)].span();
    let _ = mmr_real.append(9, peaks_real);

    // add the next element abnormally to mmr_real and get the root;
    let forged_peak = PoseidonHasher::hash_double(*elems.at(6), *elems.at(7));
    let peaks_fake = array![forged_peak].span();
    let res = mmr_fake.append(9, peaks_fake);

    assert(res.is_err(), 'attack success: forged peak');
}

#[test]
#[available_gas(99999999)]
fn test_attack_forge_verify() {
    let elem1 = PoseidonHasher::hash_single(1);
    let elem2 = PoseidonHasher::hash_single(2);
    let elem3 = PoseidonHasher::hash_double(elem1, elem2);
    let elem4 = PoseidonHasher::hash_single(4);

    let mmr = MMRTrait::new(
        root: PoseidonHasher::hash_double(4, PoseidonHasher::hash_double(elem3, elem4)), last_pos: 4
    );

    let proof = array![].span();
    let peaks = array![elem3, elem4].span();

    assert(
        mmr.verify_proof(1, elem4, peaks, proof).unwrap() == false,
        'Attack successful forged verify'
    );
}
