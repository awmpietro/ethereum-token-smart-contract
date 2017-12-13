pragma solidity ^0.4.11;

/**
* @title Token
* @author Arthur Mastropietro <arthur.mastropietro@gmail.com>
*/
contract Token {

    uint256 public totalSupply; //ERC20
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping (address => uint256) public balanceOf; //ERC20
    string public name;
    string public symbol;
    mapping (address => bool) public owners;

    event Transfer(address indexed from, address indexed to, uint256 value); //ERC20
    event Approval(address indexed owner, address indexed spender, uint256 value); //ERC20
    event Burn(address indexed from, uint256 _value);

    /**
    * @dev Constructor: Here we define, when contract is deployed, the total supply of tokens, name and symbol of the contract and the owner of the contract as well, which
    * is the one who deployed
    */
    function Token(uint256 _totalSupply, string _name, string _symbol) public {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
        name = _name;
        symbol = _symbol;
        owners[msg.sender] = true;
   }

    /**
    * @dev Modifier to restrict access to certain functions only to the contract's owners
    */
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }

    /**
    * @dev Create a new owner to operate contract
    */
    function setOwner(address newOwner) external onlyOwner {
        require(owners[newOwner] == false);
        owners[newOwner] = true;
    }

    /**
    * @dev Remove an owner of the contract
    */
    function removeOwner(address oldOwner) external onlyOwner {
        require(owners[oldOwner] == true);
        owners[oldOwner] = false;
        //delete(owners[oldOwner]);


   /** 
   * @dev Transfer tokens from sender account to another account
   * ERC20
   */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to]+_value > balanceOf[_to]);
        uint previousBalances = balanceOf[msg.sender] + balanceOf[_to];
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        assert(balanceOf[msg.sender] + balanceOf[_to] == previousBalances);
        return true;
   }

    /**
    * Transfer from an account previously allowed, so sender can act in behalf of it, to another account
    * ERC20
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowed[_from][msg.sender]); //Owners can transfer from any account to another account, in case of provision
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Here is possible to allow an account to transact tokens in behalf of the sender
    * ERC20
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Here we check the amount of tokens that an account allowed to a spender transact.
    * ERC20
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Here we can increase the value of tokens for spender to transact in behalf the sender
    */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Here we can decrease the value of tokens for spender to transact in behalf the sender
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Function allows sender burn, or throw away forever, _value tokens of his own
    */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    /**
    * @dev Function allows sender burn, or throw away forever, _value tokens of another account, previously allowed by the owner of that account
    */
    function burnFrom(address _from, uint256 _value) external {
        require(balanceOf[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
    }

    /**
    * @dev Allows Contract's owner increase the number of tokens
    */
    function increaseTotalSupply(uint256 _value) external onlyOwner {
        totalSupply = totalSupply + _value;
        balanceOf[msg.sender] = balanceOf[msg.sender] + _value;
    }

    /**
    * @dev Allows Contract's owner decrease the number of tokens
    */
    function decreaseTotalSupply(uint256 _value) external onlyOwner {
        require(balanceOf[msg.sender] >= _value);
        require(totalSupply >= _value);
        totalSupply = totalSupply - _value;
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
    }

    /**
    * @dev WARNING: Game Over, this function will remove this code from Blockchain
    */
    function abortMission() external onlyOwner {
        selfdestruct(msg.sender);
    }
}