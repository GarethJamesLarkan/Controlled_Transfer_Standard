// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./IControlledERC721Transfer.sol";

abstract contract ControlledERC721Transfer is IControlledERC721Transfer {
    
    struct TransferRequest {
        uint256 tokenId;
        uint256 requestEndTime;
        address from;
        address to;
        bool approved;
    }

    // The length a transfer on a specific tokenID is valid for.
    uint256 private transferWindow;

    address private owner;

    mapping(uint256 token => TransferRequest request) private transferRequests;

    constructor(address _owner) {
        owner = _owner;
    }

    function submitTransferRequest(
        address _to, 
        uint256 _tokenId
    ) public virtual {
        require(block.timestamp > transferRequests[_tokenId].requestEndTime, "Transfer request currently active");
        
        transferRequests[_tokenId] = TransferRequest({
            tokenId: _tokenId,
            requestEndTime: 1,
            from: msg.sender,
            to: _to,
            approved: false
        });
    }

    function finalizeRequest(uint256 _tokenId, bool _decision) public virtual {
        TransferRequest memory request = transferRequests[_tokenId];
        if(msg.sender != owner) {
            revert OnlyOwnerFunction(msg.sender);
        }

        if(request.requestEndTime == 0) {
            revert NonExistentRequest();
        }

        if(block.timestamp > request.requestEndTime)

        request.requestEndTime = block.timestamp + transferWindow;
        request.approved = _decision;
    }
}