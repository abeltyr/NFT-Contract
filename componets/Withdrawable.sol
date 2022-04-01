// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./AknetAble.sol";
import "./IERC20.sol";


pragma solidity ^0.8.0;

abstract contract Withdrawable is Ownable, AknetAble {
  address[] public payableAddresses = [AKNETADDRESS, 0x38370538e95c12F3F935b87b2A75340D536D98AA];
  uint256[] public payableFees = [10,90];
  uint256 public payableAddressCount = 2;

  function withdrawAll() public onlyOwner {
      require(address(this).balance > 0);
      _withdrawAll();
  }
  
  function withdrawAllAknet() public isAKNET {
      require(address(this).balance > 0);
      _withdrawAll();
  }

  function _withdrawAll() private {
      uint256 balance = address(this).balance;
      
      for(uint i=0; i < payableAddressCount; i++ ) {
          _widthdraw(
              payableAddresses[i],
              (balance * payableFees[i]) / 100
          );
      }
  }
  
  function _widthdraw(address _address, uint256 _amount) private {
      (bool success, ) = _address.call{value: _amount}("");
      require(success, "Transfer failed.");
  }

  /**
    * @dev Allow contract owner to withdraw ERC-20 balance from contract
    * while still splitting royalty payments to all other team members.
    * in the event ERC-20 tokens are paid to the contract.
    * @param _tokenContract contract of ERC-20 token to withdraw
    * @param _amount balance to withdraw according to balanceOf of ERC-20 token
    */
  function withdrawAllERC20(address _tokenContract, uint256 _amount) public onlyOwner {
    require(_amount > 0);
    IERC20 tokenContract = IERC20(_tokenContract);
    require(tokenContract.balanceOf(address(this)) >= _amount, 'Contract does not own enough tokens');

    for(uint i=0; i < payableAddressCount; i++ ) {
        tokenContract.transfer(payableAddresses[i], (_amount * payableFees[i]) / 100);
    }
 }
}