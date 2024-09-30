use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use auction_contract::auction::{IAuctionDispatcher, IAuctionDispatcherTrait};

#[derive(Drop, Serde)]
struct AuctionArgs {
    name: ByteArray,
    symbol: ByteArray
}
fn deploy_contract(name: ByteArray) -> ContractAddress {
    let class_hash = declare(name).unwrap().contract_class();
    let mut constructor_args = array![];
    let args = AuctionArgs { name: "Auction Token", symbol: "AUCTION" };
    args.serialize(ref constructor_args);
    let (address, _) = class_hash.deploy(@constructor_args).unwrap();
    address
}


fn test_get_highest_bidder() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };


    dispatcher.register_item('item');
    dispatcher.bid('item', 42);

    let bid_after = dispatcher.get_highest_bidder('item');
    assert(bid_after == 42, 'Invalid bid amount');
}

fn test_register_item() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };

    dispatcher.register_item('item');
    let new_item = dispatcher.is_registered('item');
    assert(!new_item, 'item is not registered');
}

#[test]
fn test_is_not_registered() {
    let contract_address = deploy_contract("Auction");

    let dispatcher = IAuctionDispatcher { contract_address };
    dispatcher.register_item('item');
    dispatcher.unregister_item('item');

    let new_item = dispatcher.is_registered('item');
    assert(new_item, 'item is registered');
}

// use auction_contract::IHelloStarknetSafeDispatcher;
// use auction_contract::IHelloStarknetSafeDispatcherTrait;
// use auction_contract::IHelloStarknetDispatcher;
// use auction_contract::IHelloStarknetDispatcherTrait;

// fn deploy_contract(name: ByteArray) -> ContractAddress {
//     let contract = declare(name).unwrap().contract_class();
//     let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
//     contract_address
// }

// #[test]
// fn test_increase_balance() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let dispatcher = IHelloStarknetDispatcher { contract_address };

//     let balance_before = dispatcher.get_balance();
//     assert(balance_before == 0, 'Invalid balance');

//     dispatcher.increase_balance(42);

//     let balance_after = dispatcher.get_balance();
//     assert(balance_after == 42, 'Invalid balance');
// }

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }


