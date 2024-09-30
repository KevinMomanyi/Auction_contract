#[starknet::interface]
trait IAuction<T> {
    fn register_item(ref self: T, item_name: felt252);

    fn unregister_item(ref self: T, item_name: felt252);

    fn bid(ref self: T, item_name: felt252, amount: u32);

    fn get_highest_bidder(self: @T, item_name: felt252) -> u32;

    fn is_registered(self: @T, item_name: felt252) -> bool;
}

#[starknet::contract]
pub mod Auction {
    use super::IAuction;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        bid: Map<felt252, u32>,
        register: Map<felt252, bool>,
        name: ByteArray,
        symbol: ByteArray,
    }
    //TODO Implement interface and events .. deploy contract
    #[constructor]
    fn constructor(ref self: ContractState, name: ByteArray, symbol: ByteArray) {
        self.name.write(name);
        self.symbol.write(symbol);
    }

    #[abi(embed_v0)]
    impl AuctionImpl of IAuction<ContractState> {
        fn register_item(ref self: ContractState, item_name: felt252) {
            self.register.write(item_name, true);
        }

        fn unregister_item(ref self: ContractState, item_name: felt252) {
            let previous_item = self.register.read(item_name);
            assert(!previous_item, 'item is not registered already!');

            self.register.write(item_name, false);
        }

        fn bid(ref self: ContractState, item_name: felt252, amount: u32) {
            let item = self.register.read(item_name);
            assert(item, 'item is not registered!');
            self.bid.write(item_name, amount);
        }

        fn get_highest_bidder(self: @ContractState, item_name: felt252) -> u32 {
            let is_registered = self.register.read(item_name);
            assert(!is_registered, 'Item is not registered');
            let highest_bid = self.bid.read(item_name);
            assert(highest_bid > 0, 'No bids placed for this item');
            highest_bid
        }
        fn is_registered(self: @ContractState, item_name: felt252) -> bool {
            let is_registered = self.register.read(item_name);
            assert(!is_registered, 'Item is not registered');
            is_registered
        }
    }
}
