

abstract contract AknetERC721A is 
    Ownable,
    ERC721A,
    ERC2981,
    Withdrawable,
    ReentrancyGuard  {

        
    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) ERC721A(tokenName, tokenSymbol, 1, 15000 ) {
        _setTokenRoyalty(0,aknetRoyaltyAddress,aknetRoyaltyFee);
        _setTokenRoyalty(1,royaltyAddress,royaltyFee);
        _setDefaultRoyalty(royaltyAddress,royaltyFee);
    }
    using SafeMath for uint256;
    uint8 public CONTRACT_VERSION = 0;
    string public _baseTokenURI = "ipfs://QmbMfkUgQsxHQDVGL5WYZS7BzVJMZdgriPrSzntQriGpyq/";

    address public royaltyAddress = 0xf832759249a76140E2fa0305A3251386664688e4;
    uint96 public royaltyFee = 900;
    address public aknetRoyaltyAddress = 0x68E9662e06fDA3c27E8c4828e4b0a1C68B60E969;
    uint96 public aknetRoyaltyFee = 100;

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

    function updateMintingFee(uint256 _feeInWei) public onlyOwner {
        mintingFee = _feeInWei;
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

    function setRoyaltyFee(uint96 _feeNumerator) external onlyOwner {
        royaltyFee = _feeNumerator;
        _setTokenRoyalty(1,royaltyAddress,royaltyFee);
        _setDefaultRoyalty(royaltyAddress,royaltyFee);
    }

    function setRoyaltyAddress(address _royaltyAddress) external onlyOwner {
        royaltyAddress = _royaltyAddress;
        _setTokenRoyalty(1,royaltyAddress,royaltyFee);
        _setDefaultRoyalty(royaltyAddress,royaltyFee);
    }

    function setAknetRoyaltyFee(uint96 _feeNumerator) external isAKNET {
        aknetRoyaltyFee = _feeNumerator;
        _setTokenRoyalty(0,aknetRoyaltyAddress,aknetRoyaltyFee);
    }

    function setAknetRoyaltyAddress(address _aknetroyaltyAddress) external isAKNET {
        aknetRoyaltyAddress = _aknetroyaltyAddress;
        _setTokenRoyalty(0,aknetRoyaltyAddress,aknetRoyaltyFee);
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


