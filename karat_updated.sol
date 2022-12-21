// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Karat is ERC20,  Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;


    uint256 private _totalSupply;
    uint256 private _DECIMALFACTOR = 10 ** decimals();
    uint256 private _fixedSupply = 2 * (10 ** 9) * _DECIMALFACTOR;
    uint256 private INITIAL_MINT = 2 * (10 ** 8) * _DECIMALFACTOR;

    bool public allowTransfer;

    //Initializa the basic Parameters: Name, Token Symbol, TotalSupply Number: 2B, First Mint 10%, 0.2B
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _totalSupply = INITIAL_MINT;
        _balances[msg.sender] = INITIAL_MINT;
        allowTransfer = false;
    }
    //Mint Function, this will increase TotalSupply
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens
    function burn(uint256 _value) public onlyOwner {
        require(_value <= _balances[msg.sender] && _value > 0, "Insufficient balance");
        _balances[msg.sender] = _balances[msg.sender] - _value;
        _totalSupply = _totalSupply - _value;
        _fixedSupply = _fixedSupply - _value;
        emit Transfer(msg.sender, address(0), _value);
    }

    function currentSupply() public view onlyOwner returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _fixedSupply;
    }
    // Before token transfer hook
    function _beforeTokenTransfer(address _from, address _to, uint256 _value) internal override {
        require(allowTransfer, "Transfers are currently not allowed");
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // Transfer tokens
    event TransferWithMessage(address indexed from, address indexed to, uint256 value, string message);
    function transferwithMemo(address _to, uint256 _value, string memory _memo) public {
        _beforeTokenTransfer(msg.sender, _to, _value);
        require(_to != address(0), "Cannot transfer to zero address");
        require(_value <= _balances[msg.sender], "Insufficient balance");
        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        emit TransferWithMessage(msg.sender, _to, _value, _memo);
    }

    // Approve and transfer from another address
    function approveAndTransferFrom(address _from, address _to, uint256 _value, string memory _memo) public {
        _beforeTokenTransfer(_from, _to, _value);
        require(_to != address(0), "Cannot transfer to zero address");
        require(_value <= _allowances[_from][msg.sender], "Insufficient allowance");
        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender] - _value;
        emit TransferWithMessage(_from, _to, _value, _memo);
    }

    // Enable token transfers
    function enableTransfers() public onlyOwner {
        allowTransfer = true;
    }

    // Disable token transfers
    function disableTransfers() public onlyOwner {
        allowTransfer = false;
    }

        //Newly Mint cannot exceed the Max supply
    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");
        require((amount + _totalSupply) <= _fixedSupply, "ERC20: mint more than totalSupply");
 
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
}