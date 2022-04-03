// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

//
//
//
//                                   ,#((((((((
//                                 (#((((((###(#
//                           /##(#(((((((((#(###
//                        #(((##(((((((((##  #(%##
//                       (#(#((((((((((#(.%      *##
//                        ###((((((((#(.   .  *.  *#(
//                        #(######/(///*,.# .  , #.##
//                       ((#(#####/&%%&*\*,,./%%%%&@#
//                        ##(####/**# *#%,,,/( ***  |
//                        ,###(###  *    |  ,,*,,,,.|
//                             (####     /  \     ,*&.*
//       (@@@@,               &&####     %  @     ,/@/@                ,@@@@
//       @@@@&&&&&           ,#(####   (@&&&&@    ,,,&@              &&&&&@@@*
//       @@&&&&&&&&&&&          ,   \    °°°°   ,/               &&&&&&&&&&@@@
//       &&&&&&&&&&&&&&&&,      .@&&&.\,      ,,/*&&&@        &&&&&&&&&&&&&&&@
//       @&&&&&&&&&&&&&&&&&&     &&@&     __,,,,,,&&&*     &&&&&&&&&&&&&&&&&&&
//      @@@@&&&&&&&&&&&&&&&&&&&  &&&&&&,      ,,@&&&&   &&&&&&&&&&&&&&&&&&&@@@@
//      @@&@&&&&&&&&&&&&&&&&&&&&.%&&&&&&,     @&&&&&&  &&&&&&&&&&&&&&&&&&&&&@@(
//       &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&    @&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//       @&&&&&&&&&&&&&&&&@@@&&&&&&&&&&&&&   &&&&&&&&&&&&&@@&&&&&&&&&&&&&&&&&
//        &&&&&&&&&&&&&&&@@@@@&&&&&&&&&&&&@.@&&&&&&&&&&&&@@@@&&&&&&&&&&&&&&&&
//         &&&&&&&&&&&&&@&&&&&&&&&&&&&&&###(/##&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//          &&&&&&&&&&&&@&&&&&&&&&&&&&&&@*(((@&&&&&&&&&&&&&&&@@&&&&&&&&&&&&
//           @@@&&&@@@@@@&@@@&&&&&&&&&@@@@@.@@@@&&&&&&&&&@@@&&@@@@&&&&&&@&
//              @@&&&&&&&&&@@&&&&&&@@@@@##((/#%@@@@&&&&&&@@&&&&&&&&&&@@

/**
 * @title WoWGalaxy Contract
 * @author Ben Yu, Itzik Lerner, @RMinLA, Mai Akiyoshi, Morgan Giraud, Toomaie, Eugene Strelkov
 * @notice This contract handles minting and distribution of World of Women Galaxy tokens.
 */
contract WoWGalaxy is ERC721, ERC721Enumerable, ERC2981, ReentrancyGuard, Ownable {
    using ECDSA for bytes32;
    using Strings for uint256;
    address public royaltyAddress = 0x646B9Ed09B130899be4c4bEc114A1aA94618bE09;
    uint96 public royaltyFee = 900;

    // support eth transactions to the contract
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @notice Construct a WoWG contract instance
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _baseTokenURI Base URI for all tokens
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI
    ) ERC721(_name, _symbol) {
        baseTokenURI = _baseTokenURI;
        _setDefaultRoyalty(royaltyAddress, royaltyFee);
    }

    modifier originalUser() {
        require(msg.sender == tx.origin,"MUST_INVOKE_FUNCTION_DIRECTLY");
        _;
    }

    /**
     * @notice Update the base token URI
     */
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    /**
     * @notice read the base token URI
     */
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @notice Change the royalty fee for the collection
     */
    function setRoyaltyFee(uint96 _feeNumerator) external onlyOwner {
        royaltyFee = _feeNumerator;
        _setDefaultRoyalty(royaltyAddress, royaltyFee);
    }

    /**
     * @notice Change the royalty address where royalty payouts are sent
     */
    function setRoyaltyAddress(address _royaltyAddress) external onlyOwner {
        royaltyAddress = _royaltyAddress;
        _setDefaultRoyalty(royaltyAddress, royaltyFee);
    }

}