This is a sample of how you might store ENS names and Ethereum addressess in a homogenous array in Solidity

The basic idea is that both things can be represented in the same bytes32 primitive.
- Ethereum address (20 bytes) can be right padded to put in a bytes32
- ENS names when name hashed are already 32 bytes

Then we can look at the last 12 bytes to decide if a bytes32 is a namehash or an address at retrieval time.
- If it is a namehash, we call the ENS on chain resolver interfaces to resolve the backing Ethereum address and return that
- If it is an Ethereuma address, then we simply cast to the address type by truncating the last 12 bytes

Credit to Serenae.eth for the idea on the ENS Discord!