import { BigNumber } from "ethers";
import { PewCore } from "./../typechain/contracts/PewCore";
import { PewNFT } from "./../typechain/contracts/IPewNFT.sol/PewNFT";
import { PewNFTFactory } from "./../typechain/contracts/PewNFTFactory";
import { expect } from "chai";

const { ethers, deployments } = require("hardhat");

describe("PewCore", function () {
  let owner: any;
  let pewCore: PewCore;
  let pewNftFactory: PewNFTFactory;

  before(async function () {
    // Get Signers
    [owner] = await ethers.getSigners();

    // Setup Test
    await deployments.fixture(["PewCore", "PewNFTFactory"]);

    pewCore = await ethers.getContract("PewCore", owner);
    pewNftFactory = await ethers.getContract("PewNFTFactory", owner);
  });

  it("Start DAO and Join", async function () {
    await pewCore.createDAO(
      "PewDAO",
      "PD",
      "QmZtaXqhcRbfBSNERmo9wKHvkTpug76ivuzM1ZTD3NcpDt"
    );

    await pewCore.joinDAO(0);

    const daoAddr = await pewCore.getContract(0);
    console.log("🚀 | dao", daoAddr);
    let dao: PewNFT = await ethers.getContractAt("PewNFT", daoAddr, owner);
    console.log(await dao.tokenURI(0));
  });
});
