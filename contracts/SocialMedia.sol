// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./UserNFT.sol";
import "./IUserNFT.sol";

contract SocialMedia is AccessControl {
    bytes32 MainAdmin = keccak256("MainAdmin");
    bytes32 GroupMod = keccak256("GroupMod");
    bytes32 GroupMemeber = keccak256("GroupMember");
    bytes32 User = keccak256("User");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Private State Variables
    uint256 private _nextTokenId;

    // All Mappings

    mapping(address => address) public UserCollection;

    mapping(address => uint256) public UserNFTPostCounter;
    mapping(uint256 => mapping(address => PostStruct)) public UserNFTPost;
    mapping(address => UserDetails) public UserMapping;

    PostStruct[] public postArray;
    CommentStruct[] public Allcomment;

    // All Struct

    struct UserDetails {
        string Name;
        address UserAddress;
        address UserNFTCollection;
        bool UserRole;
    }

    struct PostStruct {
        address CollectionAddress;
        string Post;
        uint256 TokenId;
        CommentStruct[] CommentsArray;
    }

    struct CommentStruct {
        string Name;
        string Comment;
    }

    // Function to create roles

    // User Role
    function CreateUserRole(address _user) internal returns (bool) {
        _grantRole(User, _user);
        return true;
    }

    // GroupMod Role
    function CreateGroupModRole(address _groupMod) internal {
        _grantRole(GroupMod, _groupMod);
    }

    // User Role
    function CreateGroupMemberRole(address _groupMember) internal {
        _grantRole(GroupMemeber, _groupMember);
    }

    // Funcoion for creating users
    function CreateUserAccount(string memory _name) external {
        UserNFT createUser = new UserNFT(address(this));

        UserDetails memory details;
        details.Name = _name;
        details.UserAddress = msg.sender;
        details.UserRole = CreateUserRole(msg.sender);
        details.UserNFTCollection = address(createUser);
        UserMapping[msg.sender] = details;
        UserCollection[msg.sender] = address(createUser);
    }

    // Function for User to Create Post
    function UserPost(string memory _post) external {
        //   uint256 tokenId = _nextTokenId++;
        UserNFTPostCounter[msg.sender] = UserNFTPostCounter[msg.sender] + 1;

        require(hasRole(User, msg.sender), "You have not Created Account");
        IUserNFT(UserCollection[msg.sender]).safeMint(
            msg.sender,
            _post,
            UserNFTPostCounter[msg.sender]
        );
        PostStruct storage postdetails = UserNFTPost[
            UserNFTPostCounter[msg.sender]
        ][msg.sender];
        postdetails.CollectionAddress = UserCollection[msg.sender];
        postdetails.Post = _post;
        postdetails.TokenId = UserNFTPostCounter[msg.sender];

        UserNFTPost[UserNFTPostCounter[msg.sender]][msg.sender] = postdetails;
        postArray.push(postdetails);
    }

    // Function to Comment on Post
    function CommentOnPost(
        address _userAddress,
        uint256 _tokenid,
        string memory _comment,
        string memory _name
    ) external {
        require(hasRole(User, msg.sender), "You have not Created Account");
        CommentStruct memory comment = CommentStruct(_name, _comment);
        PostStruct storage addcomment = UserNFTPost[_tokenid][_userAddress];
        addcomment.CommentsArray.push(comment);
        Allcomment.push(comment);
    }

    // // Function to receive ERC721 Tokens
    // function getOnERC721ReceivedSelector() public pure returns (bytes4) {
    //     return IERC721Receiver.selector;
    // }
}
