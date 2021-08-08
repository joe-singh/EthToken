/* Sample Smart Contract to deploy a custom token on the Ethereum Blockchain. Follows the
 * ECR-20 Standard https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
 *
 * For free public use. By Jyotirmai Singh */

pragma solidity 0.8.6;

/* ECR-20 Standard Abstract Contract Methods */

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

/* Contract to implement ownership of a token, by defining the owner and
   changing ownership. */

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

/* Token smart contract, implementing ECR20 and Owned contracts */
contract Token is ECR20Interface, Owned {

    // Symbol of the token
    string public symbol;

    // Token name
    string public name;

    // Decimal places to which token is denominated
    uint8 public decimals;

    // Total supply of tokens in circulation
    uint public _totalSupply;

    // Address that can mint new coins and distribute them
    address _centralBank;

    // Mapping to keep track of how many tokens each address has
    mapping(address => uint) balances;

    constructor () {
        symbol = "Tk";
        name = "Token";
        decimals = 0;
        _totalSupply = 100;

        // This is my (Jyotirmai Singh's) public ethereum addresss! Put your
        // own here!
        _centralBank = 0xD1e2f37D48d87D11ceA7ea93a374bAc0ed2DfCa7;

        // Start by giving the central bank the full initial supply
        balances[_centralBank] = _totalSupply;

        // Store a record of the transfer of tokens to the central bank
        // on the Ethereum Blockchain
        emit Transfer(address(0), _centralBank, _totalSupply);

    }

    /* Return the total supply of coins in circulation.
     * Equal to the total supply minus any coins sent to 0x0 to be burned. */
    function totalSupply() public override view returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    /* Return the number of tokens owned by TokenOwner */
    function balanceOf(address TokenOwner) public override view returns (uint) {
        return balances[TokenOwner];
    }

    /* Transfer tokens from the invoker of the contract to the address to.
     * Emit an event to store a record of the transfer on the blockchain.
     * Return true if successful */
    function transfer(address to, uint tokens) public override returns (bool) {
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    /* Mints amount new tokens and adds them to the global supply. Only the
     * the central bank address can invoke this method. Returns true if successful. */
    function mint(uint amount) public returns (bool) {
        require(msg.sender == _centralBank);
        balances[_centralBank] += amount;
        _totalSupply += amount;
        return true;
    }

    /* Removes amount tokens from address target. Only the
     * the central bank address can invoke this method. If the amount is larger
     * than target's balance, the account is emptied to 0. Returns true if
     * successful. */
    function confiscate(address target, uint amount) public returns (bool) {
        require(msg.sender == _centralBank);

        if (balances[target] >= amount) {
            balances[target] -= amount;
        } else {
            balances[target] = 0;
        }
        return true;
    }

    /* This is to allow other people to spend from my balance. I am not implementing
     * this since I don't want my token to have this ability, but I am leaving it
     * in case I want to implement it later to comply with the ERC-20 standard. */
    function approve(address spender, uint tokens) public override returns (bool) {
        return true;
    }

    /* This is to allow a third party to transfer from the address from to address to,
     * up to a specified amount tokens. I am not implementing this since I don't
     * want my token to have this ability, but I am leaving it in case I want to
     * implement it later to comply with the ERC-20 standard. */
    function transferFrom(address from, address to, uint tokens) public override returns (bool) {
        return true;
    }


    /* This is to show how much a spender can spend from tokenOwner's balance. I
     * set this to 0 since I don't want third parties to be able to transfer
     * balances between other accounts. */
    function allowance(address TokenOwner, address spender) public override view returns (uint) {
        return 0;
    }
}
