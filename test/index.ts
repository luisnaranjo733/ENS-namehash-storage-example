/* eslint-disable node/no-missing-import */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { AddressHodler } from "../typechain";
const namehash = require("@ensdomains/eth-ens-namehash");

describe("AddressHodler", function () {
  let contract: AddressHodler;
  // eslint-disable-next-line no-unused-vars
  let owner: SignerWithAddress;

  // `beforeEach` will run before each test, re-deploying the contract every time
  beforeEach(async () => {
    const signers = await ethers.getSigners();
    owner = signers[0];

    const factory = await ethers.getContractFactory("AddressHodler");

    contract = await factory.deploy();

    await contract.deployed();
  });

  it("works when we add a namehash", async function () {
    const nameHash = namehash.hash("alice.eth"); // 32 byte string
    await contract.addAddress(nameHash);

    expect(await contract.getBytes(0)).to.equal(nameHash);
  });

  it("works when we add a normal address", async function () {
    const address = "0xba744dde23446485cb4a175d8e78eeff2063875d";
    const bytes32address = address + "00".repeat(12);
    await contract.addAddress(bytes32address);

    expect((await contract.getAddress(0)).toLowerCase()).to.equal(address);
  });

  it("works when we add a normal address, then namehash, then normal address", async function () {
    const nameHash = namehash.hash("alice.eth"); // 32 byte string
    await contract.addAddress(nameHash);
    expect(await contract.getBytes(0)).to.equal(nameHash);

    const address = "0xba744dde23446485cb4a175d8e78eeff2063875d";
    const bytes32address = address + "00".repeat(12);
    await contract.addAddress(bytes32address);
    expect((await contract.getAddress(1)).toLowerCase()).to.equal(address);

    await contract.addAddress(nameHash);
    expect(await contract.getBytes(2)).to.equal(nameHash);
  });

  it("correctly discerns between address and ENS name", async function() {
    const nameHash = namehash.hash("alice.eth"); // 32 byte string
    await contract.addAddress(nameHash);
    const nameHashBytes = await contract.getBytes(0);

    const address = "0xba744dde23446485cb4a175d8e78eeff2063875d";
    const bytes32address = address + "00".repeat(12);
    await contract.addAddress(bytes32address);
    const addressBytes = await contract.getBytes(1);

    expect(await contract.areBytesEthereumAddress(nameHashBytes)).to.equal(
      false
    );

    expect(await contract.areBytesEthereumAddress(addressBytes)).to.equal(true);
  });
});
