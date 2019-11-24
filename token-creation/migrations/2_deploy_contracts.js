const SBToken = artifacts.require("SBToken");
const AnimalToken = artifacts.require("AnimalToken");

module.exports = function(deployer) {
  deployer.deploy(SBToken, 1000); // we mint 1000 tokens when we deploy
  deployer.deploy(AnimalToken);
};
