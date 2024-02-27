// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IUserNFT {
    function safeMint(address to, string memory uri, uint256 tokenId) external;

    function transferOwnership(address newOwner) external;
}
