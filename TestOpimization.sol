// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

// Idea is to encode 8 varibiles into one varible for optimizing
contract TestOpimization{
       uint8 a1; // 0 - 255
       uint8 a2; // 0 -> 3
       uint8 a3; // 0 -> 3
       uint8 a4; // 0 -> 7 = 3 bit
       uint8 a5; // 0 -> 127
       uint8 a6; // 0 -> 31
       uint8 a7; // 0 -> 31
    // This struct will be used to represent the attributes of CryptoSim
    function encode(uint8 a1, uint8 a2, uint8 a3, uint8 a4, uint8 a5, uint8 a6, uint8 a7) public returns(uint32){
        uint32 genes = 0;
        // a1: 255, a2: 2 bit
        genes = uint32(a1) << 24;
        genes |= uint32(a2) << 22;
        genes |= uint32(a3) << 20;
        genes |= uint32(a4) << 17;
        genes |= uint32(a5) << 10;
        genes |= uint32(a6) << 5;
        genes |= uint32(a7);
        return genes;
    }
    // decode function
    function decode(uint32 genes) public returns (uint8,uint8,uint8,uint8,uint8,uint8,uint8) {
       
       a1 = uint8((genes & (255 << 24) ) >> 24);
       a2 = uint8((genes & (3 << 22) ) >> 22);
       a3 = uint8((genes & (3 << 20 )) >> 20);
       a4 = uint8((genes & (7 << 17 )) >> 17);
       a5 = uint8((genes & (127 << 10)) >> 10);
       a6 = uint8((genes & (31 << 5)) >> 5);
       a7 = uint8(genes & 31);
       return (a1,a2,a3,a4,a5,a6,a7);
    }
}