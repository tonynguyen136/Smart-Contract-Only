# Smart-Contract-Only

Solidity Smart Contract Only
**Lottery**: 

Take note:
In this smart contract we can use random() function using abi.encodePacked it's called: Pseudo-random
with some parameters likc block.difficulty, block.timestamp...It is eccpected for the testing.

In fact, it may lead some potential security risks
so the idea is that we can use random with off-chain data, Chainlink is providing one of the best solutions
for communication between off-chain data to on-chain data.
