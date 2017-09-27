pragma solidity ^0.4.10;

library SafeMath {
    function add(uint a, uint b) internal returns (uint) {
        uint temp = a + b;
        if(temp >= a)
        {
            return temp;
        }else
        {
            revert();
        }
    }
    function substract(uint a, uint b) internal returns (uint) {
        if(b <= a)
        {
            uint temp = a - b;
            return temp;
        }else
        {
            revert();
        }
    }
    function multiply(uint a, uint b) internal returns (uint) {
        uint temp = a * b;
        if(a == 0 || temp / a == b)
        {
            return temp;
        }else
        {
            revert();
        }
    }
    function divide(uint a, uint b) internal returns (uint) {
        if(b > 0)
        {
            uint temp = a / b;
            if(a == b * temp + a % b)
            {
                return temp;
            }else
            {
                revert();
            }
        }else
        {
            revert();
        }
    }
}

contract Owned
{
    address public owner;
    
    function Owned()
    {
        owner = msg.sender;
    }

    modifier owned
    {
        if(msg.sender != owner)
        {
            revert();
        }else
        {
            _;
        }
    }
}

contract Token is Owned
{
    using SafeMath for uint;

    // Modifiers
        // Defend against the ERC20 short addrezs attack
        modifier fullAddress(uint size)
        {
            if(msg.data.length < size + 4)
            {
                revert();
            }else
            {
                _;
            }
        }

    // Token information
        string public constant name = "Token Name";
        string public constant symbol = "TKN";
        uint8 public constant decimals = 2;

    // Token data
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowanceOf;
        uint public totalSupply = 100000;

    // Functions and events necessary for the ERC20 Token Standard
        function totalSupply() constant returns (uint totalSupply)
        {
            return totalSupply;
        }
        function balanceOf(address _owner) constant returns (uint balance)
        {
            return balanceOf[_owner];
        }
        function transfer(address _to, uint _value) fullAddress(2 * 32) returns (bool)
        {
            balanceOf[msg.sender] = balanceOf[msg.sender].substract(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        function transferFrom(address _from, address _to, uint _value) fullAddress(3 * 32) returns (bool)
        {
            balanceOf[_from] = balanceOf[_from].substract(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            allowanceOf[_from][msg.sender] = allowanceOf[_from][msg.sender].substract(_value);
            Transfer(_from, _to, _value);
            return true;
        }
        function approve(address _spender, uint _value) returns (bool)
        {
            if(_value != 0 && allowanceOf[msg.sender][_spender] != 0)
            {
                revert();
            }else
            {
                allowanceOf[msg.sender][_spender] = _value;
                Approval(msg.sender, _spender, _value);
                return true;
            }
        }
        function allowance(address _owner, address _spender) constant returns (uint)
        {
            return allowanceOf[_owner][_spender];
        }
        event Transfer(address indexed _from, address indexed _to, uint _value);
        event Approval(address indexed _owner, address indexed _spender, uint _value);
    // Constructor
        function Token()
        {
            balanceOf[owner] = totalSupply;
        }

    // Other functions
        function burn(uint _value) owned returns (bool)
        {
            balanceOf[msg.sender] = balanceOf[msg.sender].substract(_value);
            totalSupply = totalSupply.substract(_value);
            Transfer(msg.sender, 0x0, _value);
            return true;
        }
}