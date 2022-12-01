// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.13 and less than 0.9.0
pragma solidity ^0.8.13;

contract Fuixlabs {
    string public greet = "Fuixlabs says hi!";

    struct NFT {
        string name; // keccak256-hash string
        string policyId; // hex-string
        string assetName; // should be equal name field
        int quantity; // shoule be 1
        bool mint;
        bool burn;
    }

    NFT[] public nfts;

    function mint(string calldata _assetName, string calldata _policyId) public {
        nfts.push(NFT(_assetName, _policyId, _assetName, 1, true, false));
    }

    function searchByAssetName(string calldata _assetName) public view returns (NFT memory nft) {
        for (uint _index = 0; _index < nfts.length; _index += 1) {
            NFT storage nft = nfts[_index];
            if (keccak256(abi.encodePacked(nft.assetName)) == keccak256(abi.encodePacked(_assetName))) {
                return NFT(nft.assetName, nft.policyId, nft.assetName, nft.quantity, nft.mint, nft.burn);
            }
        }
        return NFT("", "", "", 0, false, false);
    }

    function burn(uint _index) public {
        NFT storage nft = nfts[_index];
        nft.burn = true;
        nft.mint = false;
    }
}
