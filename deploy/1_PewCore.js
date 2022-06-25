const { ethers } = require("hardhat");
const { GasLogger } = require("../utils/helper.js");

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  let subscriptionId,
    _vrfCoordinator,
    _keyHash,
    _owner,
    _communitySignerAddress,
    _rizardSignerAddress,
    _whitelistSignerAddress;

  // https://vrf.chain.link/?_ga=2.10587508.1969588586.1654743249-750858345.1654743248
  if (chainId === "1") {
    console.log("MAINNET DEPLOYMENT");
    subscriptionId = 0;
    // https://docs.chain.link/docs/vrf-contracts/#ethereum-mainnet
    _vrfCoordinator = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
    _keyHash =
      "0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef";
    _owner = "0x0000000000000000000000000000000000000000";
  } else if (chainId === "4") {
    console.log("RINKEBY DEPLOYMENT");
    subscriptionId = 6088;
    // https://docs.chain.link/docs/vrf-contracts/#rinkeby-testnet
    _vrfCoordinator = "0x6168499c0cffcacd319c818142124b7a15e857ab";
    _keyHash =
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc";
    _owner = deployer;
  } else {
    console.log("UNKNOWN CHAIN / LOCALHOST");
    subscriptionId = 6088;
    // https://docs.chain.link/docs/vrf-contracts/#rinkeby-testnet
    _vrfCoordinator = "0x6168499c0cffcacd319c818142124b7a15e857ab";
    _keyHash =
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc";
    _owner = deployer;
  }

  // Config
  console.log(`Deploying ChiefToads Contract... from ${deployer}`);
  _communitySignerAddress = "0xF24100C7C19301B7a3AbBB0e7A5754b8B35D6eF6";
  _rizardSignerAddress = "0x69ddeC3b39cD4eEA78c98A9912FED10463585801";
  _whitelistSignerAddress = "0x90cf87D7CDD10100c489e83C7C3e1b810e86A5F5";
  // uint64 subscriptionId,
  // address _vrfCoordinator,
  // bytes32 _keyHash
  // address _owner

  let NEW_OWNER = deployer; // TODO: Change to client wallet
  if (chainId === "4") {
    NEW_OWNER = "0x25BECC7487d7D2a09EbD876ab7D218Cd59D8E034";
  }
  console.log("🚀 | module.exports= | NEW_OWNER", NEW_OWNER);
  let SIGNER = "0x3ca46eE08290033639F1d59609387dBFE006eef8";

  let chiefToad = await deploy("ChiefToads", {
    from: deployer,
    args: [
      subscriptionId,
      _vrfCoordinator,
      _keyHash,
      NEW_OWNER,
      _communitySignerAddress,
      _whitelistSignerAddress,
      _rizardSignerAddress,
    ],
  });

  gasLogger.addDeployment(chiefToad);
};

module.exports.tags = ["ChiefToad"];
