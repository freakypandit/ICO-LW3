// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
   // Price of one Crypto Dev token
   uint256 public constant tokenPrice = 0.001 ether;

   // assign token per NFT
   uint256 public constant tokenPerNFT = 10 * 10 ** 18;

   // max totoalSupply
   uint256 public constant maxTotalSupply = 10000 * 10 ** 18;

   //interface call
   ICryptoDevs CryptoDevsNFT;

   //mapping to keep track of tokens claimed 
   mapping(uint256 => bool) public tokenIdsClaimed;

   constructor (address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {

      // called the interface to the contract 
      CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
   } 

   /**
       * @dev Mints `amount` number of CryptoDevTokens
       * Requirements:
       * - `msg.value` should be equal or greater than the tokenPrice * amount
   */
   function mint(uint256 amount) public payable {
      uint256 _requiredAmount = tokenPrice * amount;

      // check if the vlue is less than what's required for the token values 
      require(msg.value >= _requiredAmount, "Ether sent is incorrect");

      uint256 amountWithDecimals = amount * 10 ** 18;

      require(
         (totalSupply() + amountWithDecimals) <= maxTotalSupply, 
         "Exceeds max total supply available"
      );

      //min the ERC20 token in required amount 
      _mint(msg.sender, amountWithDecimals);
   }

   /**
       * @dev Mints tokens based on the number of NFT's held by the sender
       * Requirements:
       * balance of Crypto Dev NFT's owned by the sender should be greater than 0
       * Tokens should have not been claimed for all the NFTs owned by the sender
   */
   function claim() public {
      //get the address of sendre
      address sender = msg.sender;
      //get the NFT balance of the sender
      uint256 balance = CryptoDevsNFT.balanceOf(sender);
      //amount keeps tarack of unclaimed token IDs 
      uint256 amount = 0;

      for(uint256 i=0; i< balance; i++) {
         uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
         //if not clamied
         if(!tokenIdsClaimed[tokenId]) {
            amount+=1;
            tokenIdsClaimed[tokenId] = true;
         }
      }

      // if all clamied?
      require(amount > 0, "You have claimed token for all NFTs");

      _mint(msg.sender, amount * tokenPerNFT);
   }

   /**
        * @dev withdraws all ETH and tokens sent to the contract
        * Requirements:
        * wallet connected must be owner's address
   */
   function withdraw() public onlyOwner {
      address _owner = owner();
      uint256 amount = address(this).balance;

      (bool sent, ) = _owner.call{value: amount}("");
      require(sent, "The transaction failed");
   }

   receive() external payable {}

   fallback() external payable {}
}

