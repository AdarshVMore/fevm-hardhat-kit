// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract UIHub {
    
    struct Post {
        address creator;
        string thumbnail;
        string name;
        string description;
        uint sellValue;
        string viewAccess_url;
        string editAccess_url;
    }

    struct User {
        address nftOwner;
        Post[] designs;
    }

    struct Designer {
        address designer;
        Post[] allPosts;
    }

    Post[] public allDesigns;
    Designer[] public allDesigners;
    mapping(address => User) public users;


    function postDesign(
        string memory _thumbnail,
        string memory _name,
        string memory _description,
        uint _sellValue,
        string memory _viewAccess_url,
        string memory _editAccess_url
    ) public {
        Post memory newPost = Post(
            msg.sender,
            _thumbnail,
            _name,
            _description,
            _sellValue,
            _viewAccess_url,
            _editAccess_url
        );

        allDesigns.push(newPost);

        bool isDesigner = false;
        for (uint256 i = 0; i < allDesigners.length; i++) {
            if (allDesigners[i].designer == msg.sender) {
                allDesigners[i].allPosts.push(newPost);
                isDesigner = true;
                break;
            }
        }

        if (isDesigner) {
            uint index = allDesigners.length;
            Designer storage designer = allDesigners[index + 1];
            designer.designer = msg.sender;
            designer.allPosts.push(newPost);
        }
    }

    function buyDesign(uint256 _index) public payable {
    require(_index < allDesigns.length, "Invalid design index");
    Post memory selectedDesign = allDesigns[_index];
    require(msg.value >= uint256(selectedDesign.sellValue), "Insufficient funds");
    bool transferSuccessful = payable(selectedDesign.creator).send(msg.value);
    require(transferSuccessful, "Transfer failed");

    User storage buyer = users[msg.sender]; // Assuming you have a mapping of users

    buyer.nftOwner = msg.sender;
    buyer.designs.push(allDesigns[_index]);
    }


    function getAllDesigns() public view returns (Post[] memory) {
        return allDesigns;
    }

    function getMyNfts(address _add) public view returns (Post[] memory) {
        return users[_add].designs;
    }
}
