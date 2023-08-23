program basic_swap.aleo;

struct TokenInfo:
    name as field;
    symbol as field;
    decimals as u8;
    total_supply as u128;
    admin as address;

struct NextTokenId:
    next_token_id as field;
    admin as address;

struct BalanceKeyData:
    token as field;
    user as address;


mapping liquidity_a:
	key left as field.public;
	value right as u64.public;


mapping liquidity_b:
	key left as field.public;
	value right as u64.public;


mapping next_token_state:
	key left as boolean.public;
	value right as NextTokenId.public;


mapping tokens:
	key left as field.public;
	value right as TokenInfo.public;


mapping balances:
	key left as field.public;
	value right as u128.public;



function create_token:
    input r0 as TokenInfo.public;
    gt r0.name 0field into r1;
    assert.eq r1 true;

    finalize r0 self.caller;

finalize create_token:
    input r0 as TokenInfo.public;
    input r1 as address.public;
    get next_token_state[true] into r2;
    add r2.next_token_id 1field into r3;
    cast r3 r2.admin into r4 as NextTokenId;
    set r4 into next_token_state[true];
    set r0 into tokens[r2.next_token_id];
    cast r2.next_token_id r1 into r5 as BalanceKeyData;
    hash.bhp256 r5 into r6 as field;    set r0.total_supply into balances[r6];


function transfer:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as u128.public;

    finalize r0 self.caller r1 r2;

finalize transfer:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as u128.public;
    contains tokens[r0] into r4;
    assert.eq r4 true;
    cast r0 r1 into r5 as BalanceKeyData;
    hash.bhp256 r5 into r6 as field;    get balances[r6] into r7;
    sub r7 r3 into r8;
    set r8 into balances[r6];
    cast r0 r2 into r9 as BalanceKeyData;
    hash.bhp256 r9 into r10 as field;    get.or_use balances[r10] 0u128 into r11;
    add r11 r3 into r12;
    set r12 into balances[r10];
