// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.13 and less than 0.9.0
pragma solidity ^0.8.13;

contract Fuixlabs {
    string private greet = "Fuixlabs says hi!";

    address private owner;

    enum Status {
        Mint,
        Burn,
        NotFound
    }

    struct NFT {
        string name; // keccak256-hash string
        string policyId; // hex-string
        string assetName; // should be equal name field
        int quantity; // shoule be 1
        Status status;
        int index;
        string assetId; // policyId + assetName
    }

    NFT[] private nfts;

    event Log(address indexed sender, string message);

    constructor() {
        owner = msg.sender;
        emit Log(msg.sender, greet);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }

    function mint(string calldata _policyId, string calldata _assetName) public onlyOwner {
        emit Log(msg.sender, "Mint an NFT");
        string memory _assetId = string(abi.encodePacked(_policyId, _assetName));
        nfts.push(NFT(_assetName, _policyId, _assetName, 1, Status.Mint, -1, _assetId));
    }

    function searchByAssetName(string calldata _assetName) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (keccak256(abi.encodePacked(nft.assetName)) == keccak256(abi.encodePacked(_assetName))) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
            }
        }
        return NFT("", "", "", 0, Status.NotFound, -1, "");
    }

    function searchByPolicyId(string calldata _policyId) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (keccak256(abi.encodePacked(nft.policyId)) == keccak256(abi.encodePacked(_policyId))) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
            }
        }
        return NFT("", "", "", 0, Status.NotFound, -1, "");
    }

    function searchByIndex(uint _index) public view returns (NFT memory nft) {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        NFT storage nft = nfts[_index];
        return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
    }

    function burn(uint _index) public onlyOwner {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        emit Log(msg.sender, "Burn an NFT");
        NFT storage nft = nfts[_index];
        nft.status = Status.Burn;
    }

    function statusOf(uint _index) public view returns (Status) {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        NFT storage nft = nfts[_index];
        return nft.status;
    }

    function statusOf(string calldata _assetId) public view returns (Status) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (keccak256(abi.encodePacked(nft.assetId)) == keccak256(abi.encodePacked(_assetId))) {
                return nft.status;
            }
        }
        return Status.NotFound;
    }
}
