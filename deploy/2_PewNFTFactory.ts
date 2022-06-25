import "dotenv/config";

import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("Chain ID:", chainId);

  // Get PEW core contract

  let pewCore = await deployments.get("PewCore");

  let pewNFTFactory = await deploy("PewNFTFactory", {
    from: deployer,
    args: [pewCore.address],
  });

  gasLogger.addDeployment(pewNFTFactory);

  // set pewNFTFactory on PEW core contract
  let owner = (await ethers.getSigners())[0];
  pewCore = await ethers.getContractAt("PewCore", pewCore.address, owner);
  await pewCore.setPewNFTFactory(pewNFTFactory.address);
};

module.exports.tags = ["PewNFTFactory"];
