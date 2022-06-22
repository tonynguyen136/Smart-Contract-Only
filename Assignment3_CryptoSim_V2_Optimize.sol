// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheFunixCryptoSim is ERC721, Ownable  {

    // TASK #1: Define Name and Symbol of our Token
    // - Symbol: FCS
    // - Name: TheFunixCryptoSims
    // HINTS:
    // - Call [name] function and [symbol] function to check
    //
	
    // *** START Code here***
    
    constructor() ERC721("TheFunixCryptoSims", "FCS") {		
        createGenesis();
    }
    
    // *** END Code here***
    //uint32 public test =0;
    // This struct will be used to represent the attributes of CryptoSim
    struct SimAttributes {
		// 0 -> 3
        uint8 body;

        // 0 -> 7 = 3 bit
        uint8 eye;

        // 0 -> 127
        uint8 hairstyle;

        // 0 -> 31
        uint8 outfit;

        // 0 -> 31
        uint8 accessory;

        // 0 -> 3
        uint8 hiddenGenes;

        // 0 - 255
        uint8 generation;
    }

    // This struct will be used to represent one sim
    struct Sim {
        uint32 genes;
        uint256 matronId;
        uint256 sireId;
    }
    
    // List of existing sims. Use as CryptoSims' "database"
    Sim[] public sims;
    
    // Event that will be emitted whenever a new sim is created
    event Birth(
        address owner,
        uint256 id,
        uint256 matronId,
        uint256 sireId,
        uint32 genes
    );

    /** @dev Function to determine a sim's characteristics.
      * @param matronId ID of sim's matron (one parent)
      * @param sireId ID of sim's sire (other parent)
      * @return The sim's new genes
      */
    function generateSimGenes(
        uint256 matronId,
        uint256 sireId
    )
        internal
        returns (uint32)
    {
        SimAttributes memory matronAttr = decodeAttributes(sims[matronId].genes);
        SimAttributes memory sireAttr = decodeAttributes(sims[sireId].genes);

        // TASK #2: Define HiddenGenes X of new Sim
        uint8 x = matronAttr.hiddenGenes;
        // START Code here
        if (matronAttr.hiddenGenes == sireAttr.hiddenGenes) {
            x = (matronAttr.hiddenGenes + sireAttr.hiddenGenes + 3) % 4;
        } else if (x < sireAttr.hiddenGenes) {
            x = sireAttr.hiddenGenes;
        }
        // END Code here

        
        // Init new object to store new Sim's attributes 
        SimAttributes memory attributes = SimAttributes({
          body: 0,
          eye: 0,
          hairstyle: 0,
          outfit: 0,
          accessory: 0,
          hiddenGenes: 0,
          generation: 0
        });

        // TASK #3: Calculate new Sim's generation
        attributes.generation = matronAttr.generation + 1;
        if (sireAttr.generation > matronAttr.generation) {
            // START CODE HERE
            attributes.generation = sireAttr.generation + 1;
            // END CODE HERE
        }

        // TASK #4: Calculate remaining atrributes
        // START CODE HERE
        if (x==0) {
            // define the body of new Sim 
            attributes.body = (matronAttr.body + sireAttr.body + 3) % 4;
            // define the eye of new Sim
            attributes.eye = sireAttr.eye;
            // define the hairstyle of new Sim
            attributes.hairstyle = matronAttr.hairstyle;
            // define the outfit of new Sim
            attributes.outfit = (matronAttr.outfit + sireAttr.outfit  + 1) % 32;
            // define the accessory of new Sim
            attributes.accessory = (matronAttr.accessory + sireAttr.accessory) % 32;
            // define the hiddenGene of new Sim
            attributes.hiddenGenes = 0;
        } else if (x==1) {
            // define the body of new Sim 
            attributes.body = (matronAttr.body + sireAttr.body + 3) % 4;
            // define the eye of new Sim
            attributes.eye = matronAttr.eye;
            // define the hairstyle of new Sim
            attributes.hairstyle = (sireAttr.hairstyle - matronAttr.hairstyle + 128) % 128;
            // define the outfit of new Sim
            attributes.outfit = (matronAttr.outfit + sireAttr.outfit  + 1) % 32;
            // define the accessory of new Sim
            attributes.accessory = (matronAttr.accessory + sireAttr.accessory) % 32;
            // define the hiddenGene of new Sim
            attributes.hiddenGenes = 1;
        } else if (x==2) {
            // define the body of new Sim 
            attributes.body = (matronAttr.body + sireAttr.body + 3) % 4;
            // define the eye of new Sim
            attributes.eye = (matronAttr.eye + sireAttr.eye) % 8;
            // define the hairstyle of new Sim
            attributes.hairstyle = (sireAttr.hairstyle - matronAttr.hairstyle + 128) % 128;
            // define the outfit of new Sim
            attributes.outfit = (matronAttr.outfit + sireAttr.outfit) % 32;
            // define the accessory of new Sim
            attributes.accessory = (matronAttr.accessory + sireAttr.accessory + 31) % 32;
            // define the hiddenGene of new Sim
            attributes.hiddenGenes = 2;
        } else if  (x==3) {
            // define the body of new Sim 
            attributes.body = (matronAttr.body + sireAttr.body + 3) % 4;
            // define the eye of new Sim
            attributes.eye = (matronAttr.eye + sireAttr.eye) % 8;
            // define the hairstyle of new Sim
            attributes.hairstyle = sireAttr.hairstyle;
            // define the outfit of new Sim
            attributes.outfit = (matronAttr.outfit + sireAttr.outfit) % 32;
            // define the accessory of new Sim
            attributes.accessory = (matronAttr.accessory + sireAttr.accessory + 31) % 32;
            // define the hiddenGene of new Sim
            attributes.hiddenGenes = 3;
        }
        // END CODE HERE

        return encodeAttributes(attributes);
    }


    /** @dev Function to create a new sim
      * @param matron ID of new sim's matron (one parent)
      * @param sire ID of new sim's sire (other parent)
      * @param owner Address of new sim's owner
      * @return The new sim's ID
      */
    function createSim(
        uint256 matron,
        uint256 sire,
        address owner
    )
        internal
        returns (uint)
    {
        require(owner != address(0));

        // Create new sim attributes based on matron and sire
        uint32 newGenes = generateSimGenes(matron, sire);
        
        Sim memory newSim = Sim({
            genes: newGenes,
            matronId: matron,
            sireId: sire
        });

        // Add new Sim to array of sims
        sims.push(newSim);
        uint256 newSimId =  sims.length -  1;

        // Create new NFT with ID is New Sim's ID, and owner is defined
        super._mint(owner, newSimId);

        // Emit Birth event
        emit Birth(
            owner,
            newSimId,
            newSim.matronId,
            newSim.sireId,
            newSim.genes
        );
        return newSimId;
    }


    function createGenesis() internal {
        // READMORE: There is better way to init create Genesis without encoding
        // TASK #7: Implement without encoding

        // START CODE HERE 
        /* [0,0,3,7,127,31,31]

        SimAttributes memory firstAtrributes = SimAttributes({
          body: 0,
          eye: 0,
          hairstyle: 0,
          outfit: 0,
          accessory: 0,
          hiddenGenes: 0,
          generation: 0
        });

        SimAttributes memory secondAtrributes = SimAttributes({
          body: 3,
          eye: 7,
          hairstyle: 127,
          outfit: 31,
          accessory: 31,
          hiddenGenes: 0,
          generation: 0
        });

        */
        // [3,7,127,31,31,0,0]
        sims.push(Sim({
            genes: 0, // genes of firstAtrributes
            matronId: 0,
            sireId: 0
        }));

        super._mint(msg.sender, 0);

        sims.push(Sim({
            genes: 4194303, // genes of secondAtrributes
            matronId: 0,
            sireId: 0
        }));

        super._mint(msg.sender, 1);

        // END CODE HERE
    }

  
    /** @dev Function to allow user to buy a new sim (calls createSim())
      * @return The new sim's ID
      */
    function buySim() external payable returns (uint256) {
		// READ MORE: In the real project, we will check whether 0.02 ether is sent. 
        // require(msg.value == 0.02 ether);
        
        return createSim(0, (sims.length - 1) % sims.length, msg.sender);
    }
    
    /** @dev Function to breed 2 sims to create a new one
      * @param matronId ID of new sim's matron (one parent)
      * @param sireId ID of new sim's sire (other parent)
      * @return The new sim's ID
      */
    function breedSim(uint256 matronId, uint256 sireId) external payable returns (uint256) {
        // READ MORE: In the real project, we will check whether 0.02 ether is sent. 
        // require(msg.value == 0.05 ether);
        return createSim(matronId, sireId, msg.sender);
    }
    
    /** @dev Function to retrieve a specific sim's details.
      * @param simId ID of the sim who's details will be retrieved
      * @return An array, [Sim's ID, Sim's genes, matron's ID, sire's ID]
      */
    function getSimDetails(uint256 simId) external view returns (uint256, uint32, uint256, uint256) {
        Sim storage sim = sims[simId];
        return (simId, sim.genes, sim.matronId, sim.sireId);
    }
    
    /** @dev Function to get a list of owned sims' IDs
      * @return A uint array which contains IDs of all owned sims
      */
    function ownedSims() external view returns(uint256[] memory) {
        uint256 simCount = balanceOf(msg.sender);
        if (simCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](simCount);
            uint256 totalSims = sims.length;
            uint256 resultIndex = 0;
            uint256 simId = 0;
            while (simId < totalSims) {

                if (ownerOf(simId) == msg.sender) {
                    result[resultIndex] = simId;
                    resultIndex = resultIndex + 1;
                }

                simId = simId + 1;
            }
            return result;
        }
    }
	
	function encodeAttributes(SimAttributes memory attributes) internal returns (uint32) {
        uint32 genes = 0;

        // TASK #5: Encode attributes into uint32
        // START CODE HERE
        /*
        // 0 - 255 = 8 bit
        uint8 generation;
        // 0 -> 3 = 2 bit
        uint8 hiddenGenes;
        //// 0 -> 3 = 2 bit 
        uint8 body;
        // 0 -> 7  = 3 bit
        uint8 eye;
        // 0 -> 127  = 7 bit
        uint8 hairstyle;
        // 0 -> 31   = 5 bit
        uint8 outfit;
        // 0 -> 31   = 5 bit
        uint8 accessory;
        */
        //[3,7,127,31,31,2,255]
        // Shift 24 bits for generation (8 bits/ 32 bits)
        genes = uint32(attributes.generation) << 24;
        // Shift 22 bits for hiddenGenes (2 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.hiddenGenes) << 22;
        // Shift 20 bits for body (2 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.body) << 20;
        // Shift 17 bits for eye (3 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.eye) << 17;
        // Shift 10 bits for hairstyle (7 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.hairstyle) << 10;
        // Shift 5 bits for outfit (5 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.outfit) << 5;
        // the last accessory (5 bits/ 32 bits) and OR with above genes
        genes |= uint32(attributes.accessory);
        // END CODE HERE
        return genes;
	}

    function decodeAttributes(uint32 genes) internal returns (SimAttributes memory) {
        SimAttributes memory attributes = SimAttributes({
          body: 0,
          eye: 0,
          hairstyle: 0,
          outfit: 0,
          accessory: 0,
          hiddenGenes: 0,
          generation: 0
        });
        // TASK #6: Decode uint32 gene to attributes
        // START CODE HERE
        // get generation (8bits) 0-255 - create mark with first 8 bits then AND with genes
        attributes.generation = uint8((genes & (255 << 24) ) >> 24);
        // get hiddenGenes (2bits) 0-3 - create mark with 2 bits then AND with genes
        attributes.hiddenGenes = uint8((genes & (3 << 22) ) >> 22);
        // get body (2bits) 0-3 - create mark with 2 bits then AND with genes
        attributes.body = uint8((genes & (3 << 20 )) >> 20);
        //get eye (3bits) 0-7 - create mark with 3 bits then AND with genes
        attributes.eye = uint8((genes & (7 << 17 )) >> 17);
        //get hairstyle (7bits) 0-127 - create mark with 7 bits then AND with genes
        attributes.hairstyle = uint8((genes & (127 << 10)) >> 10);
        //get outfit (5bits) 0-31 - create mark with 5 bits then AND with genes
        attributes.outfit = uint8((genes & (31 << 5)) >> 5);
        //get accessory (5bits) 0-31 - create mark with last 5 bits then AND with genes
        attributes.accessory = uint8(genes & 31);
        // END CODE HERE

        return attributes;
	}
}