// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookAccessControl {
    event addedBook(string message); 

    struct Book {
        string title;
        string author;
        uint256 isbn;
        uint256 price;
        address[] authorizedReaders;
        // uint authorizedReadersCount;
        // mapping(address => bool) authorized;
        // mapping(address => uint256) lastAccessTime;
    }
    
    mapping (uint256 => Book) books;

    function addBook(string memory _title, string memory _author, uint256 _isbn, uint256 _price) public {
        require(books[_isbn].isbn == 0, "Book with this ISBN already exists");
        Book memory temp = Book({title: _title,author: _author,isbn: _isbn,price: _price,authorizedReaders: new address[](0)});
        // Book memory temp = Book({title: _title,author: _author,isbn: _isbn,price: _price,authorizedReaders: new address[](0), authorizedReadersCount: 1});
        books[_isbn] = temp;
        emit  addedBook("Book added") ;
    }
    
    function authorizeReader(uint256 _isbn, address _reader) public payable{
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        require(msg.sender == books[_isbn].authorizedReaders[0], "Only the book owner can authorize readers");
        // books[_isbn].authorized[_reader] = true;
        books[_isbn].authorizedReaders.push(_reader);
        // books[_isbn].authorizedReadersCount += 1;
    }
    
    function requestAccess(uint256 _isbn) public payable {
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        //require(books[_isbn].authorized[msg.sender], "You are not authorized to access this book");
        bool authorized = false;
        for (uint i = 1; i < books[_isbn].authorizedReaders.length; i++){
            if(msg.sender == books[_isbn].authorizedReaders[i]){
                authorized = true;
                break;
            }
        }
        require(authorized, "You are not authorized to access this book");
        require(msg.value == books[_isbn].price, "Incorrect payment amount");
        //require(block.timestamp - books[_isbn].lastAccessTime[msg.sender] > 1 days, "You cannot access this book more than once a day");
        //books[_isbn].lastAccessTime[msg.sender] = block.timestamp;
        // give access to book content
    }
}