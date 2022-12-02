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

    NFT private natural = NFT("", "", "", 0, Status.NotFound, -1, "");

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

    function compare(string memory lhs, string memory rhs) public pure returns (bool) {
        return keccak256(abi.encodePacked(lhs)) == keccak256(abi.encodePacked(rhs));
    }

    function searchByAssetName(string calldata _assetName) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (compare(nft.assetName, _assetName)) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
            }
        }
        return natural;
    }

    function searchByPolicyId(string calldata _policyId) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (compare(nft.policyId, _policyId)) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
            }
        }
        return natural;
    }

    function searchByAssetId(string calldata _assetId) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (compare(nft.assetId, _assetId)) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
            }
        }
        return natural;
    }

    function searchByIndex(uint _index) public view returns (NFT memory nft) {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        NFT storage nft = nfts[_index];
        NFT memory resp = NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
        return resp;
    }

    function burn(uint _index) public onlyOwner {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        emit Log(msg.sender, "Burn an NFT");
        NFT storage nft = nfts[_index];
        if (nft.status == Status.Burn) {
            revert("Already burned");
        }
        nft.status = Status.Burn;
    }

    function statusOf(uint _index) public view returns (Status) {
        NFT memory nft = searchByIndex(_index);
        return nft.status;
    }

    function statusOf(string calldata _assetId) public view returns (Status) {
        NFT memory nft = searchByAssetId(_assetId);
        return nft.status;
    }
}
