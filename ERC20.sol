//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract ERC20 {
    string Name ;
    string Symbol ;
    uint256 public supply;
    mapping(address => uint256) public balances ;
    mapping(address => mapping(address=>uint256)) public allowances;
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    constructor(string memory _name , string memory _symbol) {
        _name = Name ;
        _symbol = Symbol ;
    }

    function name() public view returns (string memory) {
        return Name;
    }

    function symbol() public view returns (string memory) {
        return Symbol;
    }

    function totalSupply() public view returns (uint256) {
        return supply;
    } 

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function transfer(address _to, uint256 value) external returns(bool success) {
        return transfertemplate(msg.sender, _to, value);
    }

    function approve(address _to, uint256 _value ) external returns (bool) {
        require(balances[msg.sender] >= _value , "Insufficienct funds") ;
        allowances[msg.sender][_to] = _value ;
        emit Approval(msg.sender,_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to ,uint256 _value) public returns (bool success) {
        _to = msg.sender;
        require(allowances[_from][_to] >= _value , "Allowances Limit Reached") ;
        uint256 currentallowances = allowances[_from][_to]; 
        allowances[_from][_to] = currentallowances - _value ;
        return transfertemplate(_from,_to,_value); 
    }

    function transfertemplate(address _from, address _to, uint256 _value) private returns (bool) {
        uint256 inwallet = balances[_from] ;
        require(inwallet >= _value , "Insufficient Funds");
        balances[_from] = inwallet - _value ;
        balances[_to] += _value ;
        emit Transfer(_from,_to,_value);
        return true;
    }


  function deposit() public payable returns (bool) {
        require(msg.sender != address(0) , "Recipient Address Invalid");
        uint256 x_value = msg.value * 1000;
        supply += x_value ;
        balances[msg.sender] += x_value ;
        return true ;
    }



    function redeem(uint256 _value) external payable {
        require(balances[msg.sender] >0 , "You Don't Have Any Tokens");
        require(balances[msg.sender] >= _value , "Not Enough Tokens In Wallet");
        balances[msg.sender] -= _value ;
        (bool success, ) = msg.sender.call{value:_value / 1000}("");
        require(success, "Transfer failed.");
        supply -= _value ;

    }

    function _mint(address _to, uint _value) internal {
        require(_to != address(0) , "Recipient Address Invalid");
        balances[_to] += _value  ;
        supply += _value  ;
        emit Transfer(address (0),_to,_value);
    }
    function burn(address from, uint _value) internal {
        require(from != address(0) , "Recipient Address Invalid");
        balances[from] -= _value  ;
        supply -= _value  ;
        emit Transfer(from,address(0),_value);
    }

}