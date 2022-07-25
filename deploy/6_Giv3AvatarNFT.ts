import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  // Get Image Storage Contract
  const giv3Core = await deployments.get("Giv3Core");

  // Get Image Storage Static Contract
  const imageStorage = await deployments.get("ImageStorage");

  let contract = await deploy("Giv3AvatarNFT", {
    from: deployer,
    args: ["GIV3 Avatar", "GIV3NFT", giv3Core.address, imageStorage.address],
  });

  gasLogger.addDeployment(contract);
};

module.exports.tags = ["Giv3AvatarNFT", "Mumbai"];
