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

contract Token {function transfer(address _to, uint _value) returns (bool success){}}

contract Crowdsale is Owned
{
    using SafeMath for uint;

    // Modifiers
        modifier duringCrowdsale
        {
            if(startTime == 0 || now < startTime || endTime < now)
            {
                revert();
            }else
            {
                _;
            }
        }

        modifier afterCrowdsale
        {
            if(startTime == 0 || now < endTime)
            {
                revert();
            }else
            {
                _;
            }
        }

    // Events
        event ReceivedBacking(address _from, uint _value);
        event SentTokens(address _to, uint _value);

    // Crowdsale data
        Token public token;
        mapping(address => uint256) public tokensOf;
        address public beneficiary;
        uint public totalRaised;
        address[] public backers;

        // Token variables
            uint public maxTokens = 1000000;
            uint public minBacking = 100 wei;
            uint public tokensPerEther = 500;
        
        // Time variables
            uint public startTime;
            uint public endTime;
            uint public duration = 30 days;
            // Bonus periods
                uint public period_1 = 3 hours;
                uint public period_2 = 2 days;
                uint public period_3 = 7 days;
            // Bonus values
                uint public bonus_1 = 30;
                uint public bonus_2 = 20;
                uint public bonus_3 = 10;

    // Functions
        function Crowdsale(address _tokenAddress, address _beneficiary)
        {
            token = Token(_tokenAddress);
            beneficiary = _beneficiary;
        }

        function startCrowdsale() owned
        {
            if(startTime == 0)
            {
                startTime = now;
                endTime = startTime.add(duration);
            }else
            {
                revert();
            }
        }

        function() duringCrowdsale payable
        {
            if(msg.value < minBacking)
            {
                revert();
            }else
            {
                uint tokens = bonusTokens(msg.value);
                tokensOf[msg.sender] = tokensOf[msg.sender].add(tokens);
                addBacker(msg.sender);
                ReceivedBacking(msg.sender, msg.value);
            }
        }

        function bonusTokens(uint _value) internal returns(uint tokens)
        {
            uint time = now;
            if(time <= startTime.add(period_1))
            {
                tokens = _value.divide(1 ether).multiply(tokensPerEther).multiply(bonus_1.add(100)).divide(100);
            }else if(time <= startTime.add(period_2))
            {
                tokens = _value.divide(1 ether).multiply(tokensPerEther).multiply(bonus_2.add(100)).divide(100);
            }else if(time <= startTime.add(period_3))
            {
                tokens = _value.divide(1 ether).multiply(tokensPerEther).multiply(bonus_3.add(100)).divide(100);
            }else
            {
                tokens = _value.divide(1 ether).multiply(tokensPerEther);
            }
            return tokens;
        }

        function addBacker(address _backer) internal
        {
            for(uint i = 0; i < backers.length; i++)
            {
                if(backers[i] == _backer)
                    return;
            }
            backers[backers.length] = _backer;
        }

        function changeBeneficiary(address _beneficiary) owned
        {
            if(_beneficiary != 0x0)
            {
                beneficiary = _beneficiary;
            }else
            {
                revert();
            }
        }

        function changeToken(address _tokenAddress) owned
        {
            if(_tokenAddress != 0x0)
            {
                token = Token(_tokenAddress);
            }else
            {
                revert();
            }
        }

        function issueTokens() afterCrowdsale owned
        {
            for(uint i = 0; i < backers.length; i++)
            {
                token.transfer(backers[i], tokensOf[backers[i]]);
                SentTokens(backers[i], tokensOf[backers[i]]);
                tokensOf[backers[i]] = 0;
            }
        }

        function withdrawFunds() afterCrowdsale owned
        {
            if(!beneficiary.send(this.balance))
                revert();
        }
}