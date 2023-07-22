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

    mapping(address => bool) public isAssetActive;
    mapping(DigitalAssetContract => mapping(address => uint8)) public rating;

    // Event declaration
    event ListAsset(DigitalAssetContract indexed assetAddress, uint256 indexed price);
    event Rating(DigitalAssetContract indexed asset, address indexed customerAddr, uint8 star);

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
        emit ListAsset(digitalAssetContract, _assetPrice);
        return address(digitalAssetContract);
    }

    function cancelListing(address digitalAssetContract) public {
        isAssetActive[digitalAssetContract] = false;
    }

    function rateAsset(DigitalAssetContract asset, uint8 star) public {
        bool isCustomer = asset.isCustomer();
        require(isCustomer, "Not a customer");
        require(star <= 5, "Invalid rating");

        rating[asset][msg.sender] = star;
        emit Rating(asset, msg.sender, star);
    }

    function reportPlagiarism(address digitalAssetContract) public {
        isAssetActive[digitalAssetContract] = false;
    }
}
