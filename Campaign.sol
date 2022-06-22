pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign{

    struct Request{
        string description; // describes why the request is being created
        uint value; // amount of money that the manager wants to send to the vendor
        address recipient; // address that the money will be sent to
        bool complete; // true if the request has already been processed (money sent)
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    Request[] public requests; // list of requests
    address public manager;
    uint public miminumContribution;
    //address[] public approvers; // replaced
    mapping(address => bool) public approvers; 
    uint public approverCount;
    
    // modifier
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    // constructor
    function Campaign(uint minimum, address creator) public{
        //manager = msg.sender;
        manager = creator;
        miminumContribution = minimum;
    }

    // function to donate by approver
    function contribute() public payable {
        require(msg.value > miminumContribution);
        approvers[msg.sender] = true;
        approverCount++;
    }

    // called by the manager to create a new spending request
    function createRequest(string _description, uint _value, address _recipient) public restricted{
        Request memory newRequest =  Request({
            description:_description, 
            value: _value,
            recipient: _recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }

    // called by each contributor to approve a spending request
    function approveRequest(uint index) public{
        // crreate local varibles to avoid the time requests[index] is repeated
        Request storage _request = requests[index];

        require(approvers[msg.sender]);
        require(!_request.approvals[msg.sender]); // voters already voted so can exclude

        _request.approvals[msg.sender] = true; // mark the sender has voted
        _request.approvalCount++; // number of voter with "yes" votes
    }

    // after a request has gotten enough approvals, the manager can call this to get money sent to the vendor
    function finalizeRequest(uint index) public restricted{
        Request storage __request = requests[index];
        require(__request.approvalCount > (approverCount/2));
        require(!__request.complete);

        __request.recipient.transfer(__request.value);
        __request.complete = true;
          
    }

}