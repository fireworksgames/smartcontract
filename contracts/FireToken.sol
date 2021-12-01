// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// The Fire Token
contract FireToken is ERC20, ERC20Burnable,Ownable {
      

    //different blockchain has different block time
    constructor() ERC20("FireToken", "FIRE") {

    _mint(msg.sender,10 * (10 ** 9) * 10 ** decimals());

    }

    function mint(address account, uint256 amount) public onlyOwner returns (bool)  {
        _mint(account,amount);
        return true;
    }

    function batchTransfer(address[] calldata to,uint256[] calldata amount)  external {
        require(to.length == amount.length,"Length of to and amount is not same");
        //require(to)
        for(uint256 i=0;i<to.length;i++){
            transfer(to[i], amount[i]);
        }
    }


}
