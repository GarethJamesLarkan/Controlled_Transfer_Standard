// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract ControlledERC721Transfer is ERC721 {
    
    struct TransferRequest {
        uint256 tokenId;
        uint256 expiryDate;
        address from;
        address to;
        bool approved;
    }

    mapping(uint256 token => TransferRequest request) private transferRequests;

    function submitTransferRequest(
        address _to, 
        uint256 _tokenId
    ) external {
        require(msg.sender == ownerOf(_tokenId), "Not token owner");
        require(block.timestamp > transferRequests[_tokenId].expiryDate, "Transfer request currently active");
        
        transferRequests[_tokenId] = TransferRequest({
            tokenId: _tokenId,
            expiryDate: block.timestamp + transferWindowPeriod,
            from: msg.sender,
            to: _to,
            approved: false
        });
    }

}