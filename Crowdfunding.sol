// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdFunding {
    address public owner;
    address public feeWallet;  
    uint256 public feePercentage = 5;  

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    constructor() {
        owner = msg.sender;
    }

    function setFeeWallet(address _feeWallet) public onlyOwner {
        require(feeWallet == address(0), "Fee wallet can only be set once");
        feeWallet = _feeWallet;
    }

    function createCampaign(string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public onlyOwner returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline > block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(_id < numberOfCampaigns, "Campaign does not exist");

        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        // Send Fee Wallet
        uint256 feeAmount = (amount * feePercentage) / 100;
        (bool feeSent,) = payable(feeWallet).call{value: feeAmount}(""); 
        require(feeSent, "Failed to send fee to feeWallet");

        // 5% Fee of Total Campaign Donation
        campaign.amountCollected = campaign.amountCollected + amount - feeAmount;
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}