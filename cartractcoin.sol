//auth Florian PRO4

pragma solidity 0.5.0;
import {erc20_interface} from "browser/erc20_interface.sol";
import {SafeMath} from "browser/SafeMath.sol";

contract cartractcoin is erc20_interface{
    //um Overflows bei uint-Operationen vorzubeugen, wird hier die SafeMath Lib von OpenZeppelin verwendet
    using SafeMath for uint;
    
    string internal _name; //Name des Tokens
    string internal _symbol; //Symbol des Tokens
    uint8 internal _decimals; //wie viele Kommastellen der Token haben sollte
    uint256 internal _totalSupply; //das Maximum aller Tokens, "die erstellt werden"
    address payable _masterOfCTC;
    mapping(address =>uint256) internal balance; // Mapping zwischen einer Addresse und dessen "Kontostand"
    //allowed ist ein wenig kompliziert: es wird eine Addresse gemappt, welche über einen bestimmten Betrag (uint256) einer anderen
    //Addresse verfügen darf. Bsp.: Partei A hat 20 ctc und "erlaubt" Partei B über 10 ctc zu verfügen.
    mapping (address => mapping (address => uint256)) internal allowed; 
    
    //hier könnten auch Argumente übergeben werden, falls Bedarf für einen weiteren Token besteht, in unserem Fall 
    // können die Parameter ausgelassen werden
    //constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply) public{
        constructor() public{
        _masterOfCTC= msg.sender;
        _name = "CarTractCoin";
        _symbol = "CTC";
        _decimals = 0;
        _totalSupply = 1000000;
        balance[_masterOfCTC]=_totalSupply;
    }
    //returnt die Anzahl der kompletten Coins
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    //returnt den "Kontostand" des Addressen-Owners
    function balanceOf(address tokenOwner) public view returns (uint _balance){
        require(tokenOwner != address(0));
        return balance[tokenOwner];
    }
    //erlaubt es dem Spender über den betrag von uint tokens zu verfügen
    function approve(address payable spender, uint tokens) public returns (bool success){
        address tokenOwner= msg.sender;
        require(balanceOf(tokenOwner) >= tokens);
        allowed[tokenOwner][spender] = tokens;
        emit Approval(tokenOwner, spender, tokens ); // Event
        return true;
    }
    //nicht im Interface, aber zum Erhöhen vom Betrag, über die ein Spender verfügen kann, muss diese implementiert sein
    function increaseSpenderTokens(address spender, uint tokens) public returns (bool success){
        address tokenOwner= msg.sender;
        require(balanceOf(tokenOwner) >= tokens);
        allowed[tokenOwner][spender] = SafeMath.add(allowed[tokenOwner][spender],tokens);
        emit Approval(tokenOwner, spender, allowed[tokenOwner][spender] ); // Event
        return true;
    }
    //nicht im Interface, aber zum Verringerb vom Betrag, über die ein Spender verfügen kann, muss diese implementiert sein
    function decreaseSpenderTokens(address spender, uint tokens) public returns (bool success){
        address tokenOwner = msg.sender;
        require(balanceOf(tokenOwner) >= tokens);
        allowed[tokenOwner][spender] = SafeMath.sub(allowed[tokenOwner][spender],tokens);
        emit Approval(tokenOwner, spender, allowed[tokenOwner][spender] ); // Event
        return true;
    }
    //return die erlaubte Menge von Tokens, die der Spender verwenden darf
    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    //transferiert vom msg.sender einen bestimmten amount von tokens an die Adresse von "to"
     function transfer(address payable to, uint tokens) public returns (bool success){
         address tokenOwner = msg.sender;
         require(balanceOf(tokenOwner) >= tokens);
         require(to != address(0));
         balance[tokenOwner]=SafeMath.sub(balance[tokenOwner],tokens);
         balance[to]=SafeMath.add(balance[to],tokens);
        emit Transfer(tokenOwner, to, tokens);
        return true;
     }
    //damit auch jemand, der zwar keine Tokens hat, aber über "allowed Tokens" verfügt, jemanden etwas was transferieren kann, gibt es diese Funktion
    function transferFrom(address holder, address to, uint tokens) public returns (bool success){
        address allowedGuy = msg.sender;
        require(holder != address(0));
        require(to != address (0));
        require(balanceOf(holder) >= tokens);
        require(allowed[holder][allowedGuy] >= tokens);
        
        balance[holder]=SafeMath.sub(balance[holder],tokens);
        balance[to]=SafeMath.add(balance[to],tokens);
        emit Transfer(holder, to, tokens);
        return true;
    }
    //funktioniert noch nicht
    /*
    function changeEthToToken() payable public returns (bool success){
        uint256 exchange=msg.value*3;
        require(balanceOf(_masterOfCTC)>= exchange);
        _masterOfCTC.transfer(msg.value);
        balance[msg.sender]=SafeMath.add(balance[msg.sender],exchange);
        return true;
        
    }*/
    
    
}
