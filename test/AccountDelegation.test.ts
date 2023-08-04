import { expect } from "chai";
import { ethers } from "hardhat";

describe("AccountDelegation", function () {
  let contract: any;
  let manager: any;
  let user: any;

  beforeEach(async function () {
    const uniswapRouterAddress = "0x1F98431c8aD98523631AE4a59f267346ea31F984";

    [manager, user] = await ethers.getSigners();

    const accountDelegation = await ethers.getContractFactory(
      "AccountDelegation"
    );
    contract = await accountDelegation.deploy(uniswapRouterAddress);
  });

  describe("Catching Success Delegation", function () {
    it("Should set the user delegation", async function () {
      const maxLimit = ethers.parseEther("1000000");
      expect(await contract.connect(user).setDelegation(true, maxLimit))
        .to.emit(contract, "DelegationSet")
        .withArgs(true, user.address);
    });
    it("Should increase the user delegation limit", async function () {
      const maxLimit = ethers.parseEther("1000000");
      expect(await contract.connect(user).setDelegation(true, maxLimit))
        .to.emit(contract, "DelegationSet")
        .withArgs(true, user.address);

      const amount = ethers.parseEther("1000");
      expect(await contract.connect(user).increaseDelegationLimit(amount))
        .to.emit(contract, "IncreasedDelegationLimit")
        .withArgs(true, user.address);
    });
    it("Should decrease the user delegation limit", async function () {
      const maxLimit = ethers.parseEther("1000000");
      expect(await contract.connect(user).setDelegation(true, maxLimit))
        .to.emit(contract, "DelegationSet")
        .withArgs(true, user.address);

      const amount = ethers.parseEther("1000");
      expect(await contract.connect(user).decreaseDelegationLimit(amount))
        .to.emit(contract, "IncreasedDelegationLimit")
        .withArgs(true, user.address);
    });
    it("Should withdraw the user delegation", async function () {
      const maxLimit = ethers.parseEther("1000000");
      expect(await contract.connect(user).setDelegation(true, maxLimit))
        .to.emit(contract, "DelegationSet")
        .withArgs(true, user.address);

      expect(await contract.connect(user).withdrawDelegation())
        .to.emit(contract, "IncreasedDelegationLimit")
        .withArgs(true, user.address);
    });
  });

  describe("Catching Failed Delegation", function () {
    it("Should not allow admin to set, decrease, increase or withdraw the delegation", async function () {
      const maxLimit = ethers.parseEther("1000000");
      expect(contract.setDelegation(true, maxLimit)).to.be.revertedWith(
        "AccountDelegation::setDelegation: Vault Manager can not delegate"
      );
      expect(contract.withdrawDelegation()).to.be.revertedWith(
        "AccountDelegation::withdrawDelegation: Only user can perform this"
      );
      const amount = ethers.parseEther("1000");
      expect(contract.increaseDelegationLimit(amount)).to.be.revertedWith(
        "AccountDelegation::increaseDelegationLimit: Only user can perform this".toString()
      );
      expect(contract.decreaseDelegationLimit(amount)).to.be.revertedWith(
        "AccountDelegation::decreaseDelegationLimit: Only user can perform this"
      );
    });

    it("Should not only allow delegated users", async function () {
      expect(contract.connect(user).withdrawDelegation()).to.be.revertedWith(
        "AccountDelegation::decreaseDelegationLimit: User must delegate to use this"
      );
      const amount = ethers.parseEther("1000");
      expect(
        contract.connect(user).increaseDelegationLimit(amount)
      ).to.be.revertedWith(
        "AccountDelegation::decreaseDelegationLimit: User must delegate to use this"
      );
      expect(
        contract.connect(user).decreaseDelegationLimit(amount)
      ).to.be.revertedWith(
        "AccountDelegation::decreaseDelegationLimit: User must delegate to use this"
      );
    });
  });
  // Not tested properly (supposed to be tested on goerli) because of too many errors
  describe("Catching Success swap function", function () {
    it("should perform a token swap", async function () {
      const tokenInAddress = "0x07865c6e87b9f70255377e024ace6630c1eaa37f"; // USDC
      const tokenOutAddress = "0x94829DD28aE65bF4Ff6Ce3A687B1053eC7229272"; // USDT
      const ERC20TokenIn = await ethers.getContractAt("IERC20", tokenInAddress);
      const amountToSwap = ethers.parseUnits("1", 6);
      await ERC20TokenIn.transfer(contract.address, amountToSwap);
      const tokenswap = await contract
        .connect(user)
        .performTokenSwap(
          user.address,
          tokenInAddress,
          tokenOutAddress,
          amountToSwap
        );
      expect(tokenswap).to.changeTokenBalances(
        tokenInAddress,
        [user],
        [-amountToSwap]
      );
    });
  });
});
