import { ethers } from "hardhat";

async function main() {
  const uniswapRouterAddress = "0x1F98431c8aD98523631AE4a59f267346ea31F984";

  const accountDelegation = await ethers.deployContract("AccountDelegation", [
    uniswapRouterAddress,
  ]);

  await accountDelegation.waitForDeployment();

  console.log(
    `accountDelegation contract deployed to ${accountDelegation.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
