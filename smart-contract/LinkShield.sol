// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract LinkShield {

    struct Link {
        string url;
        address owner;
        uint256 fee;
        uint256 paymentCount; 
        uint256 createdAt;   
    }

    // admin do contrato
    address public immutable admin;

    // comissao
    uint256 public commission = 1;

    mapping(string => Link) private links;
    mapping(string => mapping (address => bool)) public hasAccess;

    // É executado uma unica vez. Função especial chamada somente no deploy do contrato
    constructor() {
        admin = msg.sender;
    }

    // Uma especie de middleware, semelhante aqueles de protecao de rota de nodejs(fazendo uma analogia rasa)
    modifier onlyOwner() {
        require(msg.sender == admin, "You do not have permission");
        _;
    }

    function setCommission(uint256 newCommission) public onlyOwner {
        commission = newCommission;
    }

    function addLink(string calldata url, string calldata linkId, uint256 fee) public {
        Link memory link = links[linkId];
        require(link.owner == address(0) || link.owner == msg.sender, "This linkId already has an owner");
        require(fee == 0  || fee > commission, "Fee too low");

        link.url = url;
        link.fee = fee;
        link.owner =  msg.sender;

        // data de criacao
        link.createdAt = block.timestamp;

        links[linkId] = link;
        hasAccess[linkId][msg.sender] = true;
    }

    function payLink(string calldata linkId) public payable {
        // Link memory link = links[linkId];
        Link storage link = links[linkId];

        require(link.owner != address(0), "Link not found");
        require(hasAccess[linkId][msg.sender] == false, "You already have access");
        require(msg.value >= link.fee, "Isufficient payment");

        hasAccess[linkId][msg.sender] = true;

        // contador
        link.paymentCount++;

        payable (link.owner).transfer(msg.value - commission);
        
    }

    function getLink(string calldata linkId) public view returns (Link memory) {
        Link memory link = links[linkId];
        // if(link.fee==0) return link;
        // if(hasAccess[linkId][msg.sender] == false)
        // link.url = "";
        
        if (link.fee > 0 && !hasAccess[linkId][msg.sender]) {
            // Remove apenas a URL, mas mantém o restante da struct, inclusive createdAt
            link.url = "";
        }

        return link;
    }

    //delecao um a um
    function deleteLink(string calldata linkId, address[] calldata usersToClear) public onlyOwner {
        require(links[linkId].owner != address(0), "Link does not exist");

        // Limpa acessos, se fornecido
        for (uint256 i = 0; i < usersToClear.length; i++) {
            hasAccess[linkId][usersToClear[i]] = false;
        }

        delete links[linkId];
    }

    //delecao multipla
    function deleteMultipleLinks(string[] calldata linkIds, address[][] calldata usersToClearPerLink) public onlyOwner {
        // aqui checa e compara o tamanho das listas
        require(linkIds.length == usersToClearPerLink.length, "Mismatched input lengths");

        for (uint256 i = 0; i < linkIds.length; i++) {
            string calldata linkId = linkIds[i];
            address[] calldata users = usersToClearPerLink[i];

            if (links[linkId].owner != address(0)) {
                // Limpa acessos para cada link
                for (uint256 j = 0; j < users.length; j++) {
                    hasAccess[linkId][users[j]] = false;
                }

                delete links[linkId];
            }
        }
    }

    // funcao de relatorio simples
    function getLinkMeta(string calldata linkId) public view returns (address owner, uint256 fee, uint256 paymentCount, uint256 createdAt) {
        Link memory link = links[linkId];
        return (link.owner, link.fee, link.paymentCount, link.createdAt);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        payable(admin).transfer(amount);
    }


     
}