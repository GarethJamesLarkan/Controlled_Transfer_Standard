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

    /**
     * @notice Submits a transfer request for a specific token.
     * @dev This function allows a user to submit a transfer request for a token to be transferred to a specified address.
     * @param _to The address to which the token will be transferred.
     * @param _tokenId The ID of the token to be transferred.
     * @dev The transfer request can only be submitted if there is no current request for the given token.
     */
    function submitTransferRequest(
        address _to,
        uint256 _tokenId
    ) public virtual {
        require(
            block.timestamp > transferRequests[_tokenId].requestEndTime,
            "Transfer request currently active"
        );

        transferRequests[_tokenId] = TransferRequest({
            tokenId: _tokenId,
            requestEndTime: 1,
            from: msg.sender,
            to: _to,
            approved: false
        });
    }

    /**
     * @notice Finalizes a transfer request for a specific token.
     * @dev This function can only be called by the contract owner.
     * @param _tokenId The ID of the token for which the transfer request is being finalized.
     * @param _decision The decision to approve or reject the transfer request.
     * @dev The transfer request must exist and not be expired for it to be finalized.
     * @dev The transfer request window period will be updated after finalizing the request.
     */
    function finalizeRequest(uint256 _tokenId, bool _decision) public virtual {
        TransferRequest memory request = transferRequests[_tokenId];
        if (msg.sender != owner) {
            revert OnlyOwnerFunction(msg.sender);
        }

        if (request.requestEndTime == 0) {
            revert NonExistentRequest();
        }

        if (block.timestamp > request.requestEndTime) {
            revert RequestExpired(_tokenId);
        }

        request.requestEndTime = block.timestamp + transferWindow;
        request.approved = _decision;
    }

    /**
     * @notice Updates the transfer request window period.
     * @dev Only the contract owner can call this function.
     * @param _newTransferWindowPeriod The new transfer window period to be set.
     */
    function updateTransferRequestWindow(
        uint256 _newTransferWindowPeriod
    ) public virtual {
        transferWindow = _newTransferWindowPeriod;
    }
}
