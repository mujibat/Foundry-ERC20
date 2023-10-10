// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
 contract ERC20Facet {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    uint256 internal immutable INITIAL_CHAIN_ID;

    uint8 internal immutable decimals;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

   

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

  

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
       
        uint8 _decimals
    ) {
    
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        //  uint8 immutable _decimals;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function name() public view virtual returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.name;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 allowed = ds.allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) ds.allowance[from][msg.sender] = allowed - amount;

        ds.balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    // function permit(
    //     address owner,
    //     address spender,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) public virtual {
    //     require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
    //     LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    //     // Unchecked because the only math done is incrementing
    //     // the owner's nonce which cannot realistically overflow.
    //     unchecked {
    //         address recoveredAddress = ecrecover(
    //             keccak256(
    //                 abi.encodePacked(
    //                     "\x19\x01",
    //                     DOMAIN_SEPARATOR(),
    //                     keccak256(
    //                         abi.encode(
    //                             keccak256(
    //                                 "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    //                             ),
    //                             owner,
    //                             spender,
    //                             value,
    //                             ds.nonces[owner]++,
    //                             deadline
    //                         )
    //                     )
    //                 )
    //             ),
    //             v,
    //             r,
    //             s
    //         );

    //         require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

    //         ds.allowance[recoveredAddress][spender] = value;
    //     }

    //     emit Approval(owner, spender, value);
    // }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(ds.name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            ds.totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
