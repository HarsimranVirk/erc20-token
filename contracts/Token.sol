// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
}

contract Harsimran is SafeMath {
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  uint256 public _tokenPrice = 10000000000000000;
  uint256 private _currentSupply;
  uint256 private _totalSupply;
  address payable private _tokenOwner;
  

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  constructor() {
    _tokenOwner = payable(msg.sender);
    balances[msg.sender] = safeAdd(balances[msg.sender], 1000);
    _currentSupply = 1000;
    _totalSupply = 10000;
    emit Transfer(address(0), msg.sender, 1000);
  }


  function name() public pure returns (string memory) {
    return "Harsimran";
  }

  function symbol() public pure returns (string memory) {
    return "HAR";
  }

  function decimals() public pure returns (uint8) {
    return 2;
  }

  function totalSupply() public view returns (uint256) {
    return _currentSupply;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(balances[_from] >= _value);
    require(allowed[_from][_to] >= _value);
    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    allowed[_from][_to] = safeSub(allowed[_from][_to], _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function mint(uint256 _value) public returns (bool success) {
    require(safeAdd(_currentSupply, _value) <= _totalSupply);
    
    balances[_tokenOwner] = safeAdd(balances[_tokenOwner], _value);
    _currentSupply = safeAdd(_currentSupply, _value);

    emit Transfer(address(0), _tokenOwner, _value);
    return true;
  }

  function burn(uint256 _value) public returns (bool success) {
    require(_currentSupply >= _value);
    require(balances[msg.sender] >= _value);

    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    _currentSupply = safeSub(_currentSupply, _value);

    emit Transfer(msg.sender, address(0), _value);
    return true;
  }

  function buy(uint256 _value) external payable returns (bool success) {
    require(_value <= (_totalSupply - _currentSupply));
    require(msg.value == _tokenPrice * _value, "Need to send exact value in wei");
   
    _tokenOwner.transfer(msg.value);
    mint(_value);
    balances[_tokenOwner] = safeSub(balances[_tokenOwner], _value);
    balances[msg.sender] = safeAdd(balances[msg.sender], _value);
    
    emit Transfer(_tokenOwner, msg.sender, _value);
    return true;
  }

  function sell(address payable _seller, uint256 _value) external payable returns (bool success) {
    require(msg.sender == _tokenOwner);
    require(balances[_seller] >= _value);

    balances[_seller] = safeSub(balances[_seller], _value);
    balances[_tokenOwner] = safeAdd(balances[_tokenOwner], _value);
    emit Transfer(_seller, _tokenOwner, _value);
   
    burn(_value);
    _seller.transfer(_value * _tokenPrice);
    return true;
  }
}
