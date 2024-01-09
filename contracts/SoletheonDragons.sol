// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract SoletheonDragons is ERC721URIStorage {
    uint256 private _nextID = 0;
    uint256 public mintFee = 10 ether;

    bool public bRevealed = false;

    address payable addrDev;
    address payable addrMarketing;

    string public strBaseURI = "https://raw.githubusercontent.com/Soletheon/Soletheon_NFT/main/data/json/eggs/";

    uint256 maxSupply = 5000;

    uint256 iOrganicCount = 0;
    uint256 iOrganicMax = 1500;

    uint256 iMechanicalCount = 0;
    uint256 iMechanicalMax = 1500;

    uint256 iCyborgCount = 0;
    uint256 iCyborgMax = 1500;
    
    mapping(uint256 => uint256) public mapIDToType;

    constructor(address _marketing) ERC721("SoletheonDragons", "SD") {
        addrDev = payable(msg.sender);
        addrMarketing = payable(_marketing);


    }

    modifier _onlyDev {
        require(msg.sender == addrDev, "SoletheonDragons: You are not my master.");

        _;
    }

    function mint(uint256 _type) public payable returns(uint256) {
        if(msg.sender != addrDev) {
            require(msg.value >= mintFee, "SoletheonDragons: Payment to low");
            require(_nextID < maxSupply, "SoletheonDragons: All eggs are layed.");

            uint256 devFee = (mintFee * 15) / 100;
            uint256 fee = mintFee - devFee;

            addrDev.transfer(devFee);
            addrMarketing.transfer(fee);
        }

        uint256 nftID = _nextID++;

        _mint(msg.sender, nftID);
        
        if(_type == 0) {
            require(iOrganicCount < iOrganicMax, "SoletheonDragons: All Organic are layed.");
            _setTokenURI(nftID, "0.json");
            mapIDToType[nftID] = 0;
            iOrganicCount++;
        } else if(_type == 1) {
            require(iMechanicalCount < iMechanicalMax, "SoletheonDragons: All Organic are layed.");
            _setTokenURI(nftID, "1.json");
            mapIDToType[nftID] = 1;
            iMechanicalCount++;
        } else if(_type == 2) {
            require(iCyborgCount < iCyborgMax, "SoletheonDragons: All Organic are layed.");
            _setTokenURI(nftID, "2.json");
            mapIDToType[nftID] = 2;
            iCyborgCount++;
        }

        if((balanceOf(msg.sender) > 20) && (balanceOf(msg.sender) % 20 == 0) || ((iOrganicCount + iMechanicalCount +iCyborgCount) == 4500)) {
            nftID = _nextID++;
            _mint(msg.sender, nftID);
            _setTokenURI(nftID, "3.json");
            mapIDToType[nftID] = 3;
        }

        return nftID;
    }

    function closeMint() public _onlyDev {
        maxSupply = _nextID;
    }

    function revealDragons(string memory _newBaseURI) public _onlyDev {
        strBaseURI = _newBaseURI;
        bRevealed = true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        if(bRevealed) {
            return string.concat(_baseURI(), string.concat(Strings.toString(tokenId),".json"));
        } else {
            return string.concat(_baseURI(), string.concat(Strings.toString(mapIDToType[tokenId]),".json"));
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return strBaseURI;
    }
}