pragma solidity 0.8.6;

abstract contract ECR20Interface {
    function totalSupply() virtual public view returns (uint);
    function balanceOf(address TokenOwner) virtual public view returns (uint balance);
    function allowance(address TokenOwner, address spender) virtual public view returns (uint remaining);
    function transfer(address to, uint tokens) virtual public returns (bool success);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

    contract Owned {
        address public owner;
        address public newOwner;

        event OwnershipTransferred(address indexed _from, address indexed _to);

        constructor() {
            owner = msg.sender;
        }

        function transferOwnership(address _to) public {
            require(msg.sender == owner);
            newOwner = _to;
        }

        function acceptOwnership() public {
            require(msg.sender == newOwner);
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            newOwner = address(0);
        }
    }

    contract Token is ECR20Interface, Owned {

        string public symbol;
        string public  name;
        uint8 public decimals;
        uint public _totalSupply;
        address _centralBank;

        mapping(address => uint) balances;

        constructor () {
            symbol = "Tok";
            name = "Token";
            decimals = 0;
            _totalSupply = 100;
            _centralBank = 0xD1e2f37D48d87D11ceA7ea93a374bAc0ed2DfCa7;

            balances[_centralBank] = _totalSupply;
            emit Transfer(address(0), _centralBank, _totalSupply);

        }


        function totalSupply() public override view returns (uint) {
            return _totalSupply - balances[address(0)];
        }

        function balanceOf(address TokenOwner) public override view returns (uint) {
            return balances[TokenOwner];
        }

        function transfer(address to, uint tokens) public override returns (bool) {
            require(balances[msg.sender] >= tokens);
            balances[msg.sender] -= tokens;
            balances[to] += tokens;
            emit Transfer(msg.sender, to, tokens);
            return true;
        }

        function mint(uint amount) public returns (bool) {
            require(msg.sender == _centralBank);
            balances[_centralBank] += amount;
            _totalSupply += amount;
            return true;
        }

        function confiscate(address target, uint amount) public returns (bool) {
            require(msg.sender == _centralBank);

            if (balances[target] >= amount) {
                balances[target] -= amount;
            } else {
                balances[target] = 0;
            }
            return true;
        }

        /* This is to allow other people to spend from my balance. I don't really care about
           that. Leaving it in if I want to implement it later/for consistency with the ERC-20
           standard. */
        function approve(address spender, uint tokens) public override returns (bool) {
            return true;
        }

        /* This is to allow a third party to transfer tokens from your balance, up to a
           specified amount. Leaving this unimplemented for now. */
        function transferFrom(address from, address to, uint tokens) public override returns (bool) {
            return true;
        }


        /* This is to show how much spender can spend from tokenOwner's balance. Leaving unimplemented
           for now. I don't want other people spending others' money. */
        function allowance(address TokenOwner, address spender) public override view returns (uint) {
            return 0;
        }
    }
