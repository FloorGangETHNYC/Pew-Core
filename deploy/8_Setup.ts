import { GasLogger } from "../utils/helper.js";
import { Giv3Core } from "../typechain/contracts/Giv3Core";
import { MockUSDT } from "../typechain/contracts/MockUSDT";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  let [owner] = await ethers.getSigners();
  let giv3Core: Giv3Core = await ethers.getContract("Giv3Core", deployer);

  // Create DAOS
  await giv3Core.createDAO("Humanitarian", "HUM", "Humanitarian Charity"); // Shoes
  await giv3Core.createDAO("Clothes", "CLO", "Clothes Charity"); // Clothes
  await giv3Core.createDAO("Animals", "ANI", "Animals Charity"); // Necklace
  await giv3Core.createDAO("Eyecare", "EYE", "Eye Charity"); // Glasses
  await giv3Core.createDAO("Environment", "ENV", "Environment Charity"); // Hat

  await giv3Core.joinDAO(0);

  // Send Mock USDT
  let usdt: MockUSDT = await ethers.getContract("MockUSDT", owner);
  await usdt.transfer(
    "0x134A7684027462b7d251944d14D561238E008e04",
    ethers.utils.parseEther("1000000")
  );
};

module.exports.tags = ["Giv3Core", "Setup"];
