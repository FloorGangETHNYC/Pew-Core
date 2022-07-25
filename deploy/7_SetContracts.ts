import { GasLogger } from "../utils/helper.js";
import { Giv3AvatarNFT } from "./../typechain/contracts/Giv3AvatarNFT";
import { Giv3Core } from "../typechain/contracts/Giv3Core";
import { Giv3NFTFactory } from "./../typechain/contracts/Giv3NFTFactory";
import { Giv3TreasuryFactory } from "./../typechain/contracts/Giv3TreasuryFactory";
import { MockUSDT } from "../typechain/contracts/MockUSDT";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const chainId = await getChainId();
  let [deployer] = await ethers.getSigners();
  let giv3Core: Giv3Core = await ethers.getContract("Giv3Core", deployer);
  let giv3NFTFactory: Giv3NFTFactory = await ethers.getContract(
    "Giv3NFTFactory",
    deployer
  );
  let giv3TreasuryFactory: Giv3TreasuryFactory = await ethers.getContract(
    "Giv3TreasuryFactory",
    deployer
  );
  let giv3AvatarNFT: Giv3AvatarNFT = await ethers.getContract(
    "Giv3AvatarNFT",
    deployer
  );

  // Create DAOS
  await giv3Core.setGiv3NFTFactory(giv3NFTFactory.address);
  await giv3Core.setGiv3TreasuryFactory(giv3TreasuryFactory.address);
  await giv3Core.setGiv3AvatarNFT(giv3AvatarNFT.address);
};

module.exports.tags = ["Giv3Core", "Mumbai"];
