import { GasLogger } from "../utils/helper.js";
import { ethers } from "hardhat";

require("dotenv").config();
const gasLogger = new GasLogger();

module.exports = async ({ getNamedAccounts, deployments, getChainId }: any) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log(`Deploying MOCK Contract... from ${deployer}`);
  // Config
  const INITIAL_SUPPLY = ethers.utils.parseEther("1000000000000"); // 100_000_000 Tokens

  let mockToken = await deploy("MockUSDT", {
    from: deployer,
    args: [INITIAL_SUPPLY],
  });

  gasLogger.addDeployment(mockToken);
};

module.exports.tags = ["MockUSDT", "Mumbai"];
