import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);
  let worldId;

  if (chainId === "80001" || chainId === "69" || chainId === "31337") {
    worldId = "0xABB70f7F39035586Da57B3c8136035f87AC0d2Aa";
  }

  let pewCore = await deploy("PewCore", {
    from: deployer,
    args: [worldId],
  });

  gasLogger.addDeployment(pewCore);
};

module.exports.tags = ["PewCore"];
