import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  let giv3Core = await deploy("Giv3Core", {
    from: deployer,
    args: [],
  });

  gasLogger.addDeployment(giv3Core);
};

module.exports.tags = ["Giv3Core"];
