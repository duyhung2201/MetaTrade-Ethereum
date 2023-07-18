// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DigitalAssetContract.sol";

// Declare errors
error NotEnoughListingFee();

// smart contract
contract DamMartketplace {
    // State variables
    uint256 public immutable listingFee;
    address contractOnwer;

    // assetId => customer address => asset data that the customer wants to get

    mapping(address => bool) public isAssetActive;

    // Event declaration
    event ListAsset(uint256 indexed assetId, address indexed assetAddress);

    // Modifier declaration

    using Clones for address payable;
    address payable immutable template;

    // Constructor
    constructor(uint256 listingFeeInitialized) {
        listingFee = listingFeeInitialized;
        contractOnwer = msg.sender;
        template = payable(new DigitalAssetContract());
    }

    // Function definition
    function listAsset(
        uint256 _assetPrice,
        address payable _parentAsset,
        uint256 _commissionRate
    ) public payable returns (address) {
        if (msg.value < listingFee) {
            revert NotEnoughListingFee();
        }
        DigitalAssetContract digitalAssetContract = DigitalAssetContract(
            payable(template.clone())
        );

        digitalAssetContract.initialize(_assetPrice, _parentAsset, _commissionRate);
        isAssetActive[address(digitalAssetContract)] = true;
        emit ListAsset(_assetPrice, address(digitalAssetContract));
        return address(digitalAssetContract);
    }

    function cancelListing(address digitalAssetContract) public {
        isAssetActive[digitalAssetContract] = false;
    }

    function reportPlagiarism(address digitalAssetContract) public {
        isAssetActive[digitalAssetContract] = false;
    }
}
