// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    // Struct is like an objct in JS
    // This is to specify types
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

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    )
        public
        returns (
            // Once create a campaign, return ID of campaign
            uint256
        )
    {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // Test to see if everything is okay
        require(
            campaign.deadline < block.timestamp,
            "The deadline should be a date in the future."
        );

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        // Index of newest created campaign
        return numberOfCampaigns - 1;
    }

    // Use ID of campaign you want to donate money to
    // Payable means you can send crypto currency throughout the function
    function donateToCampaign(uint256 _id) public payable {
        // get amount from frontend
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        // Let us know if transaction has been sent
        // payable accepts two different params sent & receive
        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        if (sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    // Get array of addresses of donators and array of donations
    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    // Return all campaigns
    function getCampaigns() public view returns (Campaign[] memory) {

        // Create a new variable
        // An array of campaigns with the same number of elements of numberOfCampaigns
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        // Loop through campaigns and populate variable
        for (uint i = 0; i < numberOfCampaigns; i++) {

            // Fetch the specific campaign from storage
            Campaign storage item = campaigns[i];

            // Then populate that campaign item into the array
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}
