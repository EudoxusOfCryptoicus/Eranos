const Equity = artifacts.require("Equity");

module.exports = function (deployer) {
    deployer.deploy(Equity, "");
};
