var firstContract = artifacts.require("./firstContract.sol");

module.exports = function(deployer) {
	deployer.deploy(firstContract);
};