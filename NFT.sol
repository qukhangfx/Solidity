// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.13 and less than 0.9.0
pragma solidity ^0.8.13;

// Getter functions can be declared view or pure.
// - `view` function declares that no state will be changed.
// - `pure` function declares that no state variable will be changed or read.

// Variables are declared as either storage, memory or calldata to explicitly specify the location of the data.
// - `storage` - variable is a state variable (store on blockchain)
// - `memory` - variable is in memory and it exists while a function is being called
// - `calldata` - special data location that contains function arguments

contract Fuixlabs {
    string private greet = "Fuixlabs says hi!";

    address private owner;

    enum Status {
        Mint,
        Burn,
        NotFound
    }

    enum DocumentType {
        Document,
        Credential
    }

    enum FilterBy {
        PolicyId,
        AssetName,
        AssetId
    }

    struct NFT {
        string name; // keccak256-hash string
        string policyId; // hex-string
        string assetName; // should be equal name field
        int quantity; // shoule be 1
        Status status;
        int index;
        string assetId; // policyId + assetName
        // int parent = -1;
        // DocumentType docType = DocumentType.Document | DocumentType.Credential;
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
        NFT[] memory assets = fetchNFT(FilterBy.AssetId, _assetId);
        require(assets.length == 0, "NFT minted.");
        nfts.push(NFT(_assetName, _policyId, _assetName, 1, Status.Mint, -1, _assetId));
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

    function compare(string memory X, string memory Y) private pure returns (bool) {
        return keccak256(abi.encodePacked(X)) == keccak256(abi.encodePacked(Y));
    }

    function satisfy(FilterBy filterBy, NFT memory nft, string memory pattern) private pure returns (bool) {
        if (filterBy == FilterBy.PolicyId && compare(nft.policyId, pattern)) return true;
        if (filterBy == FilterBy.AssetName && compare(nft.assetName, pattern)) return true;
        if (filterBy == FilterBy.AssetId && compare(nft.assetId, pattern)) return true;
        return false;
    }

    function fetchNFT(FilterBy filterBy, string memory pattern) private view returns (NFT[] memory) {
        uint len = 0;
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (satisfy(filterBy, nft, pattern)) {
                len += 1;
            }
        }
        NFT[] memory resp = new NFT[](len);
        uint id = 0;
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (satisfy(filterBy, nft, pattern)) {
                resp[id] = NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
                id += 1;
            }
        }
        require(id == len, "Something went wrong!");
        return resp;
    }

    function searchByAssetName(string calldata _assetName) public view returns (NFT[] memory) {
        return fetchNFT(FilterBy.AssetName, _assetName);
    }

    function searchByPolicyId(string calldata _policyId) public view returns (NFT[] memory) {
        return fetchNFT(FilterBy.PolicyId, _policyId);
    }

    function searchByAssetId(string calldata _assetId) public view returns (NFT memory) {
        NFT[] memory resp = fetchNFT(FilterBy.AssetId, _assetId);
        if (resp.length == 1) {
            return resp[0];
        }
        return natural;
    }

    function searchByIndex(uint _index) public view returns (NFT memory) {
        require(_index < nfts.length, "Index must be less than length of NFTs");
        NFT storage nft = nfts[_index];
        NFT memory resp = NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.status, int(_index), nft.assetId);
        return resp;
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
