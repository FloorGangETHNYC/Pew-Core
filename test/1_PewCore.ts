import { BigNumber } from "ethers";
import { Giv3Core } from "./../typechain/contracts/Giv3Core";
import { Giv3NFT } from "./../typechain/contracts/Giv3NFT";
import { Giv3NFTFactory } from "./../typechain/contracts/Giv3NFTFactory";
import { expect } from "chai";

const { ethers, deployments } = require("hardhat");

describe("Giv3Core", function () {
  let owner: any;
  let giv3Core: Giv3Core;
  let giv3NftFactory: Giv3NFTFactory;

  before(async function () {
    // Get Signers
    [owner] = await ethers.getSigners();

    // Setup Test
    await deployments.fixture(["Mumbai"]);

    giv3Core = await ethers.getContract("Giv3Core", owner);
    // giv3NftFactory = await ethers.getContract("Giv3NFTFactory", owner);
  });

  it("Start DAO and Join", async function () {
    await giv3Core.createDAO("Eye", "Eye", "Eye Charity");

    await giv3Core.joinDAO(0);

    const daoAddr = await giv3Core.getContract(0);
    console.log("🚀 | dao", daoAddr);
    let dao: Giv3NFT = await ethers.getContractAt("Giv3NFT", daoAddr, owner);
    console.log(await dao.tokenURI(0));
  });
});
