// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookAccessControl {

    event addedBook(address owner, string name, string author); 
    event authorizedReader (uint256 isbn, address reader);
    
    struct Book {
        address owner;
        string title;
        string author;
        uint256 isbn;
        uint256 price;
        address[] authorizedReaders;
        uint authorizedReadersCount;

        string ipfsHash;

        // mapping(address => bool) authorized;
        // mapping(address => uint256) lastAccessTime;
    }

    mapping(uint => string) isbn_hash;

    struct viewBook{
        string title;
        string author;
        uint256 isbn;
    }

    mapping(address => viewBook[]) users;
    mapping(uint256 => Book) public books;

    function addBook(string memory _title, string memory _author, uint256 _isbn, uint256 _price) public {
        require(books[_isbn].isbn == 0, "Book with this ISBN already exists");
        // Book memory temp = 
        books[_isbn] = Book({owner: msg.sender, title: _title, author: _author, isbn: _isbn, price: _price * 1 ether, authorizedReaders: new address[](0), authorizedReadersCount: 1, ipfsHash: isbn_hash[_isbn]});
        emit addedBook(msg.sender, _title, _author);
    }

    function authorizeReader(uint256 _isbn, address _reader) public payable {
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        require(msg.sender == books[_isbn].owner, "Only the book owner can authorize readers");
        // books[_isbn].authorized[_reader] = true;
        books[_isbn].authorizedReadersCount += 1;
        books[_isbn].authorizedReaders.push(_reader);

        emit authorizedReader(_isbn, _reader);
    }

    function requestAccess(uint256 _isbn) public payable {
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        bool authorize = false;
        for (uint256 i = 0; i < books[_isbn].authorizedReadersCount; i++) {
            if (msg.sender == books[_isbn].authorizedReaders[i]) {
                authorize = true;
                break;
            }
        }
        require(authorize || msg.sender == books[_isbn].owner, "You are not authorized to access this book");
        //require(books[_isbn].authorized[msg.sender], "You are not authorized to access this book");
        require(msg.value == books[_isbn].price, "Incorrect payment amount");
        //require(block.timestamp - books[_isbn].lastAccessTime[msg.sender] > 1 days, "You cannot access this book more than once a day");
        //books[_isbn].lastAccessTime[msg.sender] = block.timestamp;
        // give access to book content
    }

    function getAuthorisedReaders(uint _isbn) public view returns (address[] memory){
        require(msg.sender == books[_isbn].owner, "Only owner of the book can use this function");
        return books[_isbn].authorizedReaders;
    }
}