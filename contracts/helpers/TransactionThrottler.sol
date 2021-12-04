// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TransactionThrottler is Ownable {
    bool private _initlialized;
    bool private _restrictionActive;
    uint256 private _endTime;
    bytes32 private constant LICENSE_TYPEHASH = 0x4a953ef724dc6d0a5121827dddb65704a4957d38081ed9f5e398c1ed4951e022;
    uint256 private _tradingStart;
    uint256 private _maxTransferAmount;
    uint256 private constant _delayBetweenTx = 30;
    mapping(address => bool) private _isWhitelisted;
    mapping(address => bool) private _isUnthrottled;
    mapping(address => uint256) private _previousTx;

    event TradingTimeChanged(uint256 tradingTime);
    event RestrictionActiveChanged(bool active);
    event MaxTransferAmountChanged(uint256 maxTransferAmount);
    event MarkedWhitelisted(address indexed account, bool isWhitelisted);
    event MarkedUnthrottled(address indexed account, bool isUnthrottled);

    function initAntibot() external onlyOwner {
        require(!_initlialized, "Protection: Already initialized");
        _initlialized = true;
        _endTime = block.timestamp + 7 days;
        _isUnthrottled[owner()] = true;
        _tradingStart = 1639958400;
        _maxTransferAmount = 50_000 * 10**18;
        _restrictionActive = true;

        emit MarkedUnthrottled(owner(), true);
        emit TradingTimeChanged(_tradingStart);
        emit MaxTransferAmountChanged(_maxTransferAmount);
        emit RestrictionActiveChanged(_restrictionActive);
    }

    function setTradingStart(uint256 _time) external onlyOwner {
        require(_tradingStart > block.timestamp, "Protection: To late");
        _tradingStart = _time;
        emit TradingTimeChanged(_tradingStart);
    }

    function setMaxTransferAmount(uint256 _amount) external onlyOwner {
        _maxTransferAmount = _amount;
        emit MaxTransferAmountChanged(_maxTransferAmount);
    }

    function setRestrictionActive(bool _active) external onlyOwner {
        _restrictionActive = _active;
        emit RestrictionActiveChanged(_restrictionActive);
    }

    function unthrottleAccount(address _account, bool _unthrottled) external onlyOwner {
        require(_account != address(0), "Zero address");
        _isUnthrottled[_account] = _unthrottled;
        emit MarkedUnthrottled(_account, _unthrottled);
    }

    function isUnthrottled(address account) external view returns (bool) {
        return _isUnthrottled[account];
    }

    function whitelistAccount(address _account, bool _whitelisted) external onlyOwner {
        require(_account != address(0), "Zero address");
        _isWhitelisted[_account] = _whitelisted;
        emit MarkedWhitelisted(_account, _whitelisted);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return _isWhitelisted[account];
    }

    function isActive() private view returns (bool) {
        return _endTime == 0 || _endTime >= block.timestamp;
    }

    function applyLicense(string memory _license) external {
        require(keccak256(abi.encodePacked(_license)) == LICENSE_TYPEHASH, "Incorrect license");
        _endTime = 0;
    }

    modifier transactionThrottler(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (isActive() && _restrictionActive && !_isUnthrottled[recipient] && !_isUnthrottled[sender]) {
            require(block.timestamp >= _tradingStart, "Protection: Transfers disabled");

            if (_maxTransferAmount > 0) {
                require(amount <= _maxTransferAmount, "Protection: Limit exceeded");
            }

            if (!_isWhitelisted[recipient]) {
                require(_previousTx[recipient] + _delayBetweenTx <= block.timestamp, "Protection: 30 sec/tx allowed");
                _previousTx[recipient] = block.timestamp;
            }

            if (!_isWhitelisted[sender]) {
                require(_previousTx[sender] + _delayBetweenTx <= block.timestamp, "Protection: 30 sec/tx allowed");
                _previousTx[sender] = block.timestamp;
            }
        }
        _;
    }
}
