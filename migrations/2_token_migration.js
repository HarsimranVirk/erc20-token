const Token = artifacts.require("Harsimran");
const SafeMath = artifacts.require("SafeMath");

module.exports = function (deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(Token);
};
