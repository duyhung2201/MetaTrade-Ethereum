// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.4.21;

// // Declare errors
// error notEnoughListingFee();

// // smart contract
// contract damMartketplace {
//     // Data type definition
//     struct customerAssetData {
//         bytes32 symmetricKey;
//         bytes20 encryptedFileHash;
//         string ipfsURI;
//     }

//     struct ownerAssetData {
//         address assetOwner;
//         uint256 assetPrice;
//         string descriptionUri;
//     }

//     // State variables
//     uint256 public immutable listingFee;
//     address contractOnwer;
//     uint256 private assetId = 0;
//     // assetId => customer address => asset data that the customer wants to get
//     mapping(uint256 => mapping(address => customerAssetData))
//         private assetIdToCustomerData;
//     mapping(address => uint256) private userFund;
//     mapping(address => uint256) private userFundWithdrawable;
//     mapping(uint256 => ownerAssetData) public assetIdToOnwerData;

//     // Event declaration
//     event listedAsset(uint256 indexed assetId);

//     // Modifier declaration

//     // Constructor
//     constructor(uint256 listingFeeInitialized) {
//         listingFee = listingFeeInitialized;
//         contractOnwer = msg.sender;
//     }

//     // Function definition
//     function listAsset(string memory descriptionUri, uint256 assetPrice)
//         public
//         payable
//     {
//         if (msg.value < listingFee) {
//             revert notEnoughListingFee();
//         }
//         assetIdToOnwerData[assetId] = ownerAssetData(
//             msg.sender,
//             assetPrice,
//             descriptionUri
//         );
//         assetId += 1;
//         userFundWithdrawable[contractOnwer] += msg.value;
//         emit listedAsset(assetId);
//     }

//     function cancelListing(uint256 assetIdToCancel) public {}
// }
