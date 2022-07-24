import "dotenv/config";

import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  // Get GIV3 core contract

  let giv3Core = await deployments.get("Giv3Core");

  let giv3NFTFactory = await deploy("Giv3NFTFactory", {
    from: deployer,
    args: [giv3Core.address],
  });

  gasLogger.addDeployment(giv3NFTFactory);

  // set giv3NFTFactory on GIV3 core contract
  let owner = (await ethers.getSigners())[0];
  giv3Core = await ethers.getContractAt("Giv3Core", giv3Core.address, owner);
  await giv3Core.setGiv3NFTFactory(giv3NFTFactory.address);
};

module.exports.tags = ["Giv3NFTFactory"];
