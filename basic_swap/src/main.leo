// The 'basic_swap' program.
program basic_swap.aleo {
    struct TokenInfo {
        name: field,
        symbol: field,
        decimals: u8,
        total_supply: u128,
        admin: address
    }
    struct NextTokenId {
        next_token_id: field,
        admin: address,
    } 
    struct BalanceKeyData {
        token: field,
        user: address,
    }

    mapping liquidity_a: field => u64;
    mapping liquidity_b: field => u64;
    mapping next_token_state: bool => NextTokenId;
    // token_id => TokenInfo
    mapping tokens: field => TokenInfo;
    // BalanceKeyData => balance
    mapping balances: field => u128;

    // ====================== token ====================== //

    transition create_token(public info: TokenInfo) {
        assert(info.name > 0field);
        // TIP: self.caller == msg.sender
        return then finalize(info, self.caller);
    }

    finalize create_token(public info: TokenInfo, public caller: address) {
        let next_token: NextTokenId = Mapping::get(next_token_state, true);
        let next_token_id: field = next_token.next_token_id;
        Mapping::set(next_token_state, true, NextTokenId { 
            next_token_id: next_token_id + 1field, 
            admin: next_token.admin 
        });
        Mapping::set(tokens, next_token_id, info);
        let balance_id: field = get_balance_id(next_token_id, caller);
        Mapping::set(balances, balance_id, info.total_supply);
    }

    transition transfer(public token_id: field, public to: address, public amount: u128) {
        return then finalize(token_id, self.caller, to, amount);
    }

    finalize transfer(public token_id: field, public from: address, public to: address, public amount: u128) {
        assert(Mapping::contains(tokens, token_id));
        let bid_from: field = get_balance_id(token_id, from);
        let bal_from: u128 = Mapping::get(balances, bid_from);
        Mapping::set(balances, bid_from, bal_from - amount);

        let bid_to: field = get_balance_id(token_id, to);
        let bal_to: u128 = Mapping::get_or_use(balances, bid_to, 0u128);
        Mapping::set(balances, bid_to, bal_to + amount);
    }

    // Build a key of the mapping `balances`
    inline get_balance_id(token_: field, user_: address) -> field {
        // copy to avoid compiling error
        let token: field = token_;
        let user: address = user_;
        return BHP256::hash_to_field(BalanceKeyData {token, user});
    }
}
