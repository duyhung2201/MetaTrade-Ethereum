// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.4.19;

// Declare errors
// error PriceNotMet(uint256 price);
// error notContractOwner();
// error hashNotMatch();
// error haveNotGrantedAccess();
// error hasRequested();
// error notEnoughFund();
// error accessGrantedAlready();
// error noFundToWithdraw();
// error haveNotRegister();
// error youAreTheOwner();
// error haveNotCompareHashes();

// smart contract
contract DigitalAssetContract {
    // Data type definition
    struct customerAssetData {
        // AES-256
        string encryptedSymmetricKey; // 0x7465737400000000000000000000000000000000000000000000000000000000
        string encryptedFileHash; // fixed to 32 bytes
        string ipfsURI;
    }

    // State variables
    mapping(address => customerAssetData) private customerAddrToData; // private
    mapping(address => uint256) private userFund; // private
    mapping(address => uint256) private userFundWithdrawable; // private
    mapping(address => bool) private userComparedHashes;
    uint256 public digitalAssetPrice;
    address public owner;
    address public parentAsset;
    uint256 public commission;

    // Event declaration
    event customerFunded(address indexed customerAddr, uint256 indexed fundAmount);

    event accessGranted(string indexed ipfsURI, address indexed customerAddr);

    event refund(address indexed customerAddr, uint256 indexed fundAmount);

    // Modifier declaration
    modifier onlyOwner() {
        if (msg.sender != owner) {
            // revert notContractOwner();
            // revert("notContractOwner");
            revert();
        }
        _;
    }

    // Constructor
    function DigitalAssetContract(
        uint256 assetPrice,
        address _parentAsset,
        uint256 _commission
    ) {
        owner = msg.sender;
        digitalAssetPrice = assetPrice;
        parentAsset = _parentAsset;
        commission = _commission;
    }

    // Function definition
    function updatePrice(uint256 newPrice) public onlyOwner {
        digitalAssetPrice = newPrice;
    }

    function registerRequest() public payable {
        delete customerAddrToData[msg.sender];
        userComparedHashes[msg.sender] = false;
        if (msg.sender == owner) {
            // revert("youAreTheOwner");
            revert();
        }
        if (msg.value < digitalAssetPrice) {
            // revert("PriceNotMet" + digitalAssetPrice);
            revert();
        }
        if (userFund[msg.sender] >= digitalAssetPrice) {
            // prevent duplicate payment --> if customer has paid, they should wait for granted access to get ipfs link
            // revert("hasRequested");
            revert();
        }
        userFund[msg.sender] += msg.value;
        emit customerFunded(msg.sender, msg.value);
    }

    function grantAccess(
        address customerAddr,
        string encryptedFileHash, // fixed from 20 bytes to 32 bytes
        string encryptedSymmetricKey,
        string ipfsURI
    ) external onlyOwner {
        if (bytes(customerAddrToData[customerAddr].ipfsURI).length != 0) {
            // Cannot cancel the granted access
            // revert("accessGrantedAlready");
            revert();
        }
        if (userFund[customerAddr] < digitalAssetPrice) {
            // customer has cancelled access request --> they no longer have fund in the contract
            // revert("haveNotRegister");
            revert();
        }
        customerAddrToData[customerAddr] = customerAssetData(
            encryptedSymmetricKey,
            encryptedFileHash,
            ipfsURI
        );
        emit accessGranted(ipfsURI, customerAddr);
    }

    function compareHashes(string customerHash) external {
        if (bytes(customerAddrToData[msg.sender].ipfsURI).length == 0) {
            // revert("haveNotGrantedAccess");
            revert();
        }
        if (!compareStrings(customerHash, customerAddrToData[msg.sender].encryptedFileHash)) {
            // send back fund to customer in case of unmatch hashes
            uint256 fundAmount = userFund[msg.sender];
            userFundWithdrawable[msg.sender] += fundAmount;
            userFund[msg.sender] = 0;
            delete customerAddrToData[msg.sender];

            emit refund(msg.sender, fundAmount);
            return;
        }
        // Double check
        if (userFund[msg.sender] < digitalAssetPrice) {
            // revert("notEnoughFund");
            revert();
        }
        userFundWithdrawable[owner] += digitalAssetPrice; // pay license fee to the content owner
        userFund[msg.sender] = 0;
        userFundWithdrawable[msg.sender] = 0;
        userComparedHashes[msg.sender] = true;
    }

    function reportPlagiarism() external {
        
    }

    function getEncryptedSymmetricKey() public view returns (string memory) {
        if (userComparedHashes[msg.sender] != true) {
            // revert("haveNotCompareHashes");
            revert();
        }
        return customerAddrToData[msg.sender].encryptedSymmetricKey;
    }

    function getIpfsURI(address customerAddr) public view returns (string memory) {
        if (bytes(customerAddrToData[customerAddr].ipfsURI).length == 0) {
            // revert("haveNotGrantedAccess");
            revert();
        }
        return customerAddrToData[customerAddr].ipfsURI;
    }

    function withdrawFund() public {
        if (userFundWithdrawable[msg.sender] <= 0) {
            // revert("noFundToWithdraw");
            revert();
        }

        uint256 amountWithdraw = userFundWithdrawable[msg.sender];
        userFundWithdrawable[msg.sender] = 0;
        // bool success = msg.sender.transfer(amountWithdraw);
        msg.sender.transfer(amountWithdraw);
        // require(success, "Transfer failed");
    }

    function cancelRequest() public {
        if (bytes(customerAddrToData[msg.sender].ipfsURI).length != 0) {
            // Cannot cancel the granted access
            // revert("accessGrantedAlready");
            revert();
        }
        // can be cancelled if access has not been granted and customer has paid money
        if (userFund[msg.sender] <= 0) {
            // revert("haveNotRegister");
            revert();
        }
        delete customerAddrToData[msg.sender];
        userFundWithdrawable[msg.sender] = userFund[msg.sender];
        userFund[msg.sender] = 0;
    }

    function getPrice() public view returns (uint256) {
        return digitalAssetPrice;
    }

    function getWithdrawableFund() public view returns (uint256) {
        return userFundWithdrawable[msg.sender];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(a) == keccak256(b);
    }
}
