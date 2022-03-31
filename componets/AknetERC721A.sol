// SPDX-License-Identifier: MIT
  
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Contract.sol";
import "./Withdrawable.sol";
import "./ReentrancyGuard.sol";

abstract contract AknetERC721A is 
    Ownable,
    ERC721A,
    Withdrawable,
    ReentrancyGuard  {
    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) ERC721A(tokenName, tokenSymbol, 2, 15 ) {}
    using SafeMath for uint256;
    uint8 public CONTRACT_VERSION = 2;
    string public _baseTokenURI = "ipfs://QmbMfkUgQsxHQDVGL5WYZS7BzVJMZdgriPrSzntQriGpyq/";

    bool public mintingOpen = true;
    
    uint256 public mintingFee = 0.1 ether;
    

    
    /////////////// Admin Mint Functions
    /**
    * @dev Mints a token to an address with a tokenURI.
    * This is owner only and allows a fee-free drop
    * @param _to address of the future owner of the token
    */
    function mintToAdmin(address _to, uint256 tokenId) public onlyOwner {
        require(tokenId <= collectionSize, "Cannot mint over supply cap");
        _safeMint(_to, tokenId);
    }

    
    /////////////// GENERIC MINT FUNCTIONS
    /**
    * @dev Mints a single token to an address.
    * fee may or may not be required*
    * @param _to address of the future owner of the token
    */
    function mintNft(address _to, uint256 tokenId) public payable {
        require(tokenId <= collectionSize, "Cannot mint over supply cap");
        require(mintingOpen == true, "Minting is not open right now!");
        
        require(msg.value >= mintingFee, "Value needs to be equal or higher the mint fee!");
        
        _safeMint(_to, tokenId);
        
    }


    function openMinting() public onlyOwner {
        mintingOpen = true;
    }

    function stopMinting() public onlyOwner {
        mintingOpen = false;
    }

    function updateMintingFee(uint256 _fee) public onlyOwner {
        mintingFee = _fee;
    }

    function getPrice(uint256 _count) private view returns (uint256) {
        return mintingFee.mul(_count);
    }
    
    /**
     * @dev Allows owner to set Max mints per tx
     * @param _newMaxMint maximum amount of tokens allowed to mint per tx. Must be >= 1
     */
     function setMaxMint(uint256 _newMaxMint) public onlyOwner {
         require(_newMaxMint >= 1, "Max mint must be at least 1");
         maxBatchSize = _newMaxMint;
     }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function baseTokenURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory) {
        return ownershipOf(tokenId);
    }
}