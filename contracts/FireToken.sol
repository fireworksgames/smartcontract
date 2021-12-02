// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FireToken is ERC20, ERC20Burnable, Ownable {
    uint256 MaxSupply = 10 * (10 ** 9) * 10 ** decimals();

    constructor() ERC20("FireToken", "FIRE")  {}

    function mint(address to, uint256 amount) external onlyOwner {
        require(MaxSupply >= totalSupply() + amount,"Exceed the MaxSupply!" );
        _mint(to, amount);
    }

    function  maxSupply() external view returns (uint256){
        return MaxSupply;
    }

    function burn(uint256 amount) public override {
         _burn(_msgSender(), amount);
         MaxSupply = MaxSupply - amount;
    }
    function batchTransfer(address[] calldata to,uint256[] calldata amount)  external {
        require(to.length == amount.length,"Length of to and amount is not same.");
        //require(to)
        for(uint256 i=0;i<to.length;i++){
            transfer(to[i], amount[i]);
        }
    }
}
