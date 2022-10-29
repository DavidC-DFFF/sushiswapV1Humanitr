
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: humanitr/donators.sol


pragma solidity ^0.8.10;

// Donators 1 - Goerli : 0xaa15cac80CDdE360cD8AFc7b48395260fd63D7CA
// Donators 2 - Goerli : 0xfdd502DF67A16a6420b65ccAa79baBd20E054E80


contract Donators is Ownable {
    address public vault;
    address public migrator;
    address[] public donatorsList;
    address[] public assosList;
    address[] public assetsList;
    struct profile {
        string name;
        mapping(address => mapping(address => uint256)) balancesByAssoByAsset;
        bool exists;
    }
    mapping(address => profile) public DonatorProfile;
    constructor(address _vault, address _migrator) {
        vault = _vault;
        migrator = _migrator;
    }
    function setVault(address _vault) public onlyOwner {
        vault = _vault;
    }
    function setMigrator(address _migrator) public onlyOwner {
        migrator = _migrator;
    }
    function setNewDonator(address _donator) public onlyMigratorOrVault {
        for (uint256 i; i < donatorsList.length; i++) {
            if (donatorsList[i] == _donator) {
                return;
            }
        }
        donatorsList.push(_donator);
        DonatorProfile[_donator].exists = true;
    }
    function setNewAsso(address _asso) public onlyMigratorOrVault {
        for (uint256 i; i < assosList.length; i++) {
            if (assosList[i] == _asso) {
                return;
            }
        }
        assosList.push(_asso);
    }
    function setNewAsset(address _asset) public onlyMigratorOrVault {
        for (uint256 i; i < assetsList.length; i++) {
            if (assetsList[i] == _asset) {
                return;
            }
        }
        assetsList.push(_asset);
    }
    function updateDonatorMigrate (
        string memory _name,
        uint256 _amount,
        address _asset,
        address _assoWallet,
        address _userWallet
    ) public onlyMigrator {
// update _assosList array        
        bool _assoInList = false;
        for (uint256 i = 0 ; i < assosList.length ; i++ ) {
            if ( assosList[i] == _assoWallet ) {
                _assoInList = true;
            }
        }
        if ( !_assoInList ) {
            assosList.push(_assoWallet);
        }
// update _assetsList array        
        bool _assetInList = false;
        for (uint256 i = 0 ; i < assetsList.length ; i++ ) {
            if ( assetsList[i] == _asset ) {
                _assetInList = true;
            }
        }
        if ( !_assetInList ) {
            assetsList.push(_asset);
        }
// update DonatorProfile
    setNewDonator(_userWallet);
    DonatorProfile[_userWallet].balancesByAssoByAsset[_assoWallet][_asset] += _amount;
    DonatorProfile[_userWallet].name = _name;
    }
//
    function updateDonator(
        uint256 _amount,
        address _asset,
        address _assoWallet,
        address _userWallet
    ) public onlyVault {
        setNewDonator(_userWallet);
        setNewAsset(_asset);
        setNewAsso(_assoWallet);
        DonatorProfile[_userWallet].balancesByAssoByAsset[_assoWallet][_asset] += _amount;
    }
    function updateDonatorName(string memory _name) public {
        require(
            DonatorProfile[msg.sender].exists == true,
            "donator doesn't exist"
        );
        DonatorProfile[msg.sender].name = _name;
    }
    function getDonatorAmounts(
        address _wallet,
        address _asso,
        address _asset
    ) public view returns (uint256) {
        require(DonatorProfile[_wallet].exists, "Is not donator yet");
        return DonatorProfile[_wallet].balancesByAssoByAsset[_asso][_asset];
    }

    function getDonatorsList() public view returns (address[] memory) {
        return donatorsList;
    }
    
    function getAssetsList() public view returns (address[] memory) {
        return assetsList;
    }
    
    function getAssosList() public view returns (address[] memory) {
        return assosList;
    }

    function getDonatorName(address _donator) public view returns (string memory) {
        return DonatorProfile[_donator].name;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "Only vault can do that");
        _;
    }
    
    modifier onlyMigrator() {
        require(msg.sender == migrator, "Only migrator can do that");
        _;
    }

    modifier onlyMigratorOrVault() {
        require((msg.sender == migrator) || (msg.sender == vault), "Only migrator or vault can do that");
        _;
    }
}
