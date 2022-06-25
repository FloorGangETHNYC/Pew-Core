const { ethers } = require("hardhat");
const { GasLogger } = require("../utils/helper.js");

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  // Get PEW core contract

  const pewCore = await deployments.get("PewCore");

  let pewNFTFactory = await deploy("PewNFTFactory", {
    from: deployer,
    args: [pewCore.address],
  });

  gasLogger.addDeployment(chiefToad);
};

module.exports.tags = ["ChiefToad"];
