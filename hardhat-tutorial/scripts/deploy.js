const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS  } = require("../constants");


async function main() {

  const CryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

  const cryptoDevsTokenContract = await ethers.getContractFactory("CryptoDevToken");

  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(
    CryptoDevsNFTContract
  );

  await deployedCryptoDevsTokenContract.deployed();

  console.log("The CryptoDevs contract is deployed on %s", deployedCryptoDevsTokenContract.address);

}

main()
  .then(() => process.exit(0)) 
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });

  //The whitelist contract is deployed on 0x18b7FA42Ff583bfBe9A463D48406af21372dE4ad