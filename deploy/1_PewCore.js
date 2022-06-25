const { ethers } = require("hardhat");
const { GasLogger } = require("../utils/helper.js");

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  let pewCore = await deploy("PewCore", {
    from: deployer,
    args: [],
  });

  gasLogger.addDeployment(pewCore);
};

module.exports.tags = ["PewCore"];
