const Equity = artifacts.require("Equity");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");

contract("Equity", async accounts => {
    it("Staking 100x2", async () => {
        equity = await Equity.deployed();
        let owner = accounts[0];
        let stake_amount = web3.utils.toBN(100);
        let tier = await equity.PREFERRED();

        assert.equal(tier, 1);

        await equity.mint(accounts[1], tier, 1000);

        balance = await equity.balanceOf(owner, tier);

        stake_id = await equity.stake(tier, stake_amount, { from: owner });

        truffleAssert.eventEmitted(
            stake_id,
            "Staked",
            (ev) => {
                assert.isTrue(ev.tier.eq(tier), "Stake tier incorrect");
                assert.isTrue(ev.amount.eq(stake_amount), "Stake amount incorrect");
                assert.equal(ev.index, 1, "Stake index incorrect");
                return true;
            },
            "Stake event not emitted"
        );
    });

    it("Prevent excess stake", async() => {
        equity = await Equity.deployed();
        let tier = await equity.PREFERRED();

        try {
            await equity.stake(tier, web3.utils.toBN("10000000000"), { from: accounts[2] });
            assert.isTrue(false);
        } catch (error) {
            assert.equal(error.reason, "You cannot stake more than you own");
        }
    });
});

