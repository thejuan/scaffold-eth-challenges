// deploy/01_deploy_vendor.js

const { ethers } = require("hardhat");
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  // You might need the previously deployed yourToken:
  const yourToken = await ethers.getContract("YourToken", deployer);

  await deploy("Vendor", {
    from: deployer,
    args: [yourToken.address], // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    log: true,
  });

  const vendor = await ethers.getContract("Vendor", deployer);

  console.log("\n 🏵  Sending all 1000 tokens to the vendor...\n");

    const transferTransaction = await yourToken.transfer(
      vendor.address,
      ethers.utils.parseEther("1000")
    );

    console.log("\n    ✅ confirming...\n");
    await sleep(5000); // wait 5 seconds for transaction to propagate

    console.log("\n 🤹  Sending ownership to frontend address...\n");
    const ownershipTransaction = await vendor.transferOwnership(
      "0x3cBdbb57A592E2Ac18947983928b99E5A35fFc58"
    );
    console.log("\n    ✅ confirming...\n");
    const ownershipResult = await ownershipTransaction.wait();

  //   if (chainId !== "31337") {
  //     try {
  //       console.log(" 🎫 Verifing Contract on Etherscan... ");
  //       await sleep(5000); // wait 5 seconds for deployment to propagate
  //       await run("verify:verify", {
  //         address: vendor.address,
  //         contract: "contracts/Vendor.sol:Vendor",
  //         contractArguments: [yourToken.address],
  //       });
  //     } catch (e) {
  //       console.log(" ⚠️ Failed to verify contract on Etherscan ");
  //     }
  //   }
};

module.exports.tags = ["Vendor"];
