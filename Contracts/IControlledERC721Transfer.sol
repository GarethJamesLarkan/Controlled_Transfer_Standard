// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC-721 compliant contract.
 */
interface IControlledERC721Transfer {
    
    error OnlyOwnerFunction(address caller);

    error NonExistentRequest();

    error RequestExpired(uint256 tokenId);
}