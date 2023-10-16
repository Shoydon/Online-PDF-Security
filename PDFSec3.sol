// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookAccessControl {

    event addedBook(address owner, string name, string author); 
    event authorizedReader (uint256 isbn, address reader);
    event accessRequested(uint256 isbn, address reader);
    
    struct Book {
        address owner;
        string title;
        string author;
        uint256 isbn;
        uint256 price;
        address[] authorizedReaders;
        uint authorizedReadersCount;

        // string ipfsHash;

        // mapping(address => bool) authorized;
        // mapping(address => uint256) lastAccessTime;
    }

    struct ViewBook{
        string title;
        string author;
        uint256 isbn;
    }

    mapping(uint256 => string) ipfs_hash;   //isbn => ipfs
    mapping(address => ViewBook[]) users;   //useraddress => ViewBook[]
    mapping(uint256 => Book) public books;  //isbn => Book
    mapping(address => uint256) accessRequests; //useraddress => isbn
    uint256[] books_isbn;

    function addBook(string memory _title, string memory _author, uint256 _isbn, uint256 _price, string memory _ipfs) public {
        require(books[_isbn].isbn == 0, "Book with this ISBN already exists");
        // Book memory temp = 
        books[_isbn] = Book({
            owner: msg.sender, 
            title: _title, 
            author: _author, 
            isbn: _isbn, 
            price: _price * 1 ether, 
            authorizedReaders: new address[](0), 
            authorizedReadersCount: 1
            // ipfsHash: isbn_hash[_isbn]
            });
        ipfs_hash[_isbn] = _ipfs;
        books_isbn.push(_isbn);
        emit addedBook(msg.sender, _title, _author);
    }

    function authorizeReader(uint256 _isbn, address _reader) public payable {
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        require(msg.sender == books[_isbn].owner, "Only the book owner can authorize readers");
        uint senderString = accessRequests[msg.sender];
        require(senderString > 0);
        books[_isbn].authorizedReadersCount += 1;
        books[_isbn].authorizedReaders.push(_reader);

        ViewBook memory book = ViewBook({
            title: books[_isbn].title,
            author: books[_isbn].author,
            isbn: books[_isbn].isbn
        });
        users[_reader].push(book);

        emit authorizedReader(_isbn, _reader);
    }

    function requestAccess(uint256 _isbn) public payable {
        require(books[_isbn].isbn != 0, "Book with this ISBN does not exist");
        accessRequests[msg.sender] = _isbn;
        require(msg.value == books[_isbn].price, "Incorrect payment amount");
        emit accessRequested(_isbn, msg.sender);
    }

    function getMyBooks() public view returns (ViewBook[] memory) {
        return users[msg.sender];
    }

    function getBook(uint _isbn) public view returns (ViewBook memory){
        for(uint i = 0; i < users[msg.sender].length; i++){
            if(users[msg.sender][i].isbn == _isbn){
                return users[msg.sender][i];
            }
        }
        revert();
    }

    // function getAllBooks() public view returns (ViewBook[] memory){
    //      ViewBook[] memory viewBooks = new ViewBook[](books_isbn.length);
    //     for(uint i = 0; i < books_isbn.length; i++){
    //         viewBooks[i] = ViewBook({
    //             title: books[i].title,
    //             author: books[i].author,
    //             isbn: books[i].isbn
    //         });
    //     }
    //     return viewBooks;
    // }

    function getAuthorisedReaders(uint _isbn) public view returns (address[] memory){
        require(msg.sender == books[_isbn].owner, "Only owner of the book can use this function");
        return books[_isbn].authorizedReaders;
    }
}