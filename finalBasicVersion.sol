pragma solidity 0.5.9;
pragma experimental ABIEncoderV2;



// auth Florian_ PRO4

contract CarTract{
    struct Machine{
        address besitzer;
        uint256 kilometer;
        string[] comments;
        bool verkaufBereit;
        uint256 preis;
        address [] ServiceCompanies;
    }
     address payable[]  AngebotsAddressen;
     uint256[] Angebote;
     mapping (address=>uint256) getBackValue;
     mapping (uint256=>Machine) aMachine;
     Machine thisMachine;
     bool alreadysetted= false; 
    constructor(uint256 _fahrzeugnummer) payable public{
        require(_fahrzeugnummer>0,"Bitte Fahrzeugnummer angeben");
        thisMachine = aMachine[_fahrzeugnummer];
        thisMachine.besitzer = msg.sender;
        thisMachine.verkaufBereit = false;
    }
    function setMachine(uint256 _kilometer) public{
        require(alreadysetted!=true,"Fahrzeug wurde bereits registiert");
            alreadysetted = true;
            thisMachine.kilometer = _kilometer;
    }
    function setMachine(uint256 _kilometer,string memory _kommentar) public{
            require(alreadysetted!=true,"Fahrzeug wurde bereits registiert");
            alreadysetted = true;
            thisMachine.kilometer = _kilometer;
            thisMachine.comments[0] = _kommentar;
    }
    function setNewKm(uint256 _newKilometer) public{
        require(_newKilometer > thisMachine.kilometer,"Ein Auto kann keine km verlieren!");
        thisMachine.kilometer = _newKilometer;
    }
    function setToSale(uint256 _preis) public{
        require(msg.sender==thisMachine.besitzer,"Diesen Call darf nur der Eigentümer des Fahrzeugs machen!");
        thisMachine.verkaufBereit = true;
        thisMachine.preis = _preis*1000000000000000000;
    }
    function wantToPay() public payable {
        require(msg.value>=thisMachine.preis,"Bitte ausreichend Ether-Value für den Preis + Gas verwenden!");
        AngebotsAddressen.push(msg.sender);
        Angebote.push(msg.value/1000000000000000000);
        getBackValue[msg.sender] = msg.value;
    }
    function deal(address payable _neuerBesitzer) public{
         require(msg.sender==thisMachine.besitzer,"Diesen Call darf nur der Eigentümer des Fahrzeugs machen!");
         uint i = 0;
         while(AngebotsAddressen.length > i) {
             address payable abgelehnteAngebotsAddresse = AngebotsAddressen[i];
             if(abgelehnteAngebotsAddresse != _neuerBesitzer){
                 uint256 temp = getBackValue[abgelehnteAngebotsAddresse];
                 abgelehnteAngebotsAddresse.transfer(temp);
             }
             i = i+1;
         }
         msg.sender.transfer(thisMachine.preis);
         thisMachine.besitzer = _neuerBesitzer;
         thisMachine.verkaufBereit = false;
    }
    function setNewComment(string memory entry) public{
        thisMachine.ServiceCompanies.push(msg.sender);
        thisMachine.comments.push(entry);
    }
    
    function setNewComment(uint256 _kilometer, string memory _entry) public {
        thisMachine.kilometer = _kilometer;
        thisMachine.ServiceCompanies.push(msg.sender);
        thisMachine.comments.push(_entry);
    }
    function getMachine() public view returns (address besitzer,uint256 kilometer,string[] memory comments,bool verkaufBereit,uint256 preis){
        return (thisMachine.besitzer,thisMachine.kilometer,thisMachine.comments,thisMachine.verkaufBereit,thisMachine.preis);
    }
    function getOwner() public view returns (address){
        return thisMachine.besitzer;
    }
    function getAllComments() public view returns (string memory, address[] memory){
        string memory entries;
        entries = string(abi.encodePacked('{"Aufenthalte": ['));
        uint i = 0;
        while(i<thisMachine.comments.length){
            if(i==0){
                entries = string(abi.encodePacked(entries,thisMachine.comments[i]));
            }
            else{
                entries = string(abi.encodePacked(entries,',',thisMachine.comments[i]));
            }
        i = i+1;
    }
     entries = string(abi.encodePacked(entries,'] }'));
    return (entries,thisMachine.ServiceCompanies);
    }
    function getPrice() public view returns(uint256){
        return thisMachine.preis / 1000000000000000000 ;
    }
    function getOffers() public view returns (address payable[] memory, uint256[] memory){
        require(msg.sender==thisMachine.besitzer,"Diesen Call darf nur der Eigentümer des Fahrzeugs machen!");
        return(AngebotsAddressen,Angebote);
    }
    function getBestOffer() public view returns (address payable, uint256){
        require(msg.sender==thisMachine.besitzer,"Diesen Call darf nur der Eigentümer des Fahrzeugs machen!");
        uint i = 0;
        address payable bestOffer;
        uint256 bestOfferAmount = 0;
        while(i<Angebote.length){
            if(Angebote[i]>bestOfferAmount){
                bestOfferAmount = Angebote[i];
                bestOffer = AngebotsAddressen[i];
            }
            i = i+1;
        }
        return (bestOffer,bestOfferAmount);
    }

}
