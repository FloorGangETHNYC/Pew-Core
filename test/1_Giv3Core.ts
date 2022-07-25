import { BigNumber } from "ethers";
import { Giv3AvatarNFT } from "./../typechain/contracts/Giv3AvatarNFT";
import { Giv3Core } from "../typechain/contracts/Giv3Core";
import { Giv3NFT } from "../typechain/contracts/Giv3NFT";
import { Giv3NFTFactory } from "../typechain/contracts/Giv3NFTFactory";
import { MockUSDT } from "./../typechain/contracts/MockUSDT";
import { expect } from "chai";
import fs from "fs";

const { ethers, deployments } = require("hardhat");

describe("Giv3Core", function () {
  let owner: any;
  let giv3Core: Giv3Core;
  let giv3NftFactory: Giv3NFTFactory;
  let usdt: MockUSDT;

  before(async function () {
    // Get Signers
    [owner] = await ethers.getSigners();

    // Setup Test
    await deployments.fixture(["Mumbai"]);

    giv3Core = await ethers.getContract("Giv3Core", owner);
    usdt = await ethers.getContract("MockUSDT", owner);
    // giv3NftFactory = await ethers.getContract("Giv3NFTFactory", owner);
  });

  it("Start DAO and Join", async function () {
    await giv3Core.createDAO("Environment", "ENV", "Environment Charity"); // Hat
    await giv3Core.createDAO("Eyecare", "EYE", "Eye Charity"); // Glasses
    await giv3Core.createDAO("Animals", "ANI", "Animals Charity"); // Necklace
    await giv3Core.createDAO("Clothes", "CLO", "Clothes Charity"); // Clothes
    await giv3Core.createDAO("Humanitarian", "HUM", "Humanitarian Charity"); // Shoes

    await giv3Core.joinDAO(0);

    const daoAddr = await giv3Core.getContract(0);
    console.log("🚀 | dao", daoAddr);
    let dao: Giv3NFT = await ethers.getContractAt("Giv3NFT", daoAddr, owner);
    console.log(await dao.tokenURI(0));
  });

  it("Donate", async function () {
    // Approve all USDT to Giv3Core
    await usdt.approve(giv3Core.address, ethers.utils.parseEther("1000000"));

    // Donate USDT to DaoId 1
    await giv3Core.donate(0, ethers.utils.parseEther("1000"));

    // Get power level

    const powerLevel = await giv3Core.getPowerLevels(0, 0);
    console.log("🚀 | powerLevel", powerLevel.toString());
    const daoAddr = await giv3Core.getContract(0);
    let dao: Giv3NFT = await ethers.getContractAt("Giv3NFT", daoAddr, owner);
    console.log(await dao.tokenURI(0));
    let giv3avatarAddress = await giv3Core.GIV3_AVATAR_NFT();
    console.log("🚀 | giv3avatarAddress", giv3avatarAddress);
    let giv3Avatar: Giv3AvatarNFT = await ethers.getContractAt(
      "Giv3AvatarNFT",
      giv3avatarAddress,
      owner
    );

    console.log(await giv3Avatar.balanceOf(owner.address));

    let uri = await giv3Avatar.tokenURI(0);

    fs.writeFileSync("uri.txt", uri);
  });
});
