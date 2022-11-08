// Copyright 2022 OmniBTC Authors. Licensed under Apache-2.0 License.
module swap::beneficiary {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use swap::event::withdrew_event;
    use swap::implements::{Self, Global};

    const ERR_NO_PERMISSIONS: u64 = 301;
    const ERR_EMERGENCY: u64 = 302;
    const ERR_GLOBAL_MISMATCH: u64 = 303;

    /// Entrypoint for the `withdraw` method.
    /// Transfers withdrew fee coins to the beneficiary.
    public entry fun withdraw<X, Y>(
        global: &mut Global,
        ctx: &mut TxContext
    ) {
        assert!(!implements::is_emergency(global), ERR_EMERGENCY);
        assert!(implements::beneficiary(global) == tx_context::sender(ctx), ERR_NO_PERMISSIONS);

        let pool = implements::get_mut_pool<X, Y>(global);
        let (fee_sui, fee_token, sui_fee, token_fee) = implements::withdraw(pool, ctx);

        transfer::transfer(
            fee_sui,
            tx_context::sender(ctx)
        );
        transfer::transfer(
            fee_token,
            tx_context::sender(ctx)
        );

        let global = implements::global_id<X, Y>(pool);
        let lp_name = implements::generate_lp_name<X, Y>();

        withdrew_event(
            global,
            lp_name,
            sui_fee,
            token_fee
        )
    }
}
