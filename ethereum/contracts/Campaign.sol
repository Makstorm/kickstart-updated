// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Compaignfactory {
    address[] public deployedCompaigns;

    function createCompaign(uint minimum) public {
        Campaign newCampaing = new Campaign(minimum, msg.sender);
        deployedCompaigns.push(address(newCampaing));
    }

    function getDeployedCompaigns() public view returns (address[] memory) {
        return deployedCompaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recepient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager, "Not authorized as manager");
        _;
    }

    constructor(uint minimum, address creater) {
        manager = creater;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution, "You need to contribute more");

        if (!approvers[msg.sender]) {
            approvers[msg.sender] = true;
            approversCount++;
        }
    }

    function createRequest(
        string calldata description,
        uint value,
        address payable recepient
    ) external restricted {
        Request storage newRequest = requests.push();
        newRequest.approvalCount = 0;
        newRequest.recepient = recepient;
        newRequest.value = value;
        newRequest.description = description;
    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender], "You are not contributor");
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recepient.transfer(request.value);
        request.complete = true;
    }
}
