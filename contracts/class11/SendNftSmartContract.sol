// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract SinSoporteDeNFT {}

contract NFTSupport is IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        //selector == hash( onERC721Received(address,address,uint256,bytes) )
        // si se retorna el selector, el contrato de NFTs dirá que sí se puede enviar el NFT
        return IERC721Receiver.onERC721Received.selector;
    }
}

interface ISimpleNft {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract NFTSupportAndTransfer is IERC721Receiver {
    function executeTransfer(
        address _sc,
        address _to,
        uint256 _tokenId
    ) public {
        // con la información de los parámetros realizar el transfer
        // address(this): hace referencia al contrato actual
        // address(this) == address de NFTSupportAndTransfer
        // msg.sender == la persona o contrato que está llamando el método executeTransfer
        ISimpleNft(_sc).safeTransferFrom(address(this), _to, _tokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        // no uso los parámetros del método
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract NFTSupportAndInmediateTransfer is IERC721Receiver {
    address nftReceiver = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    // El método 'onERC721Received' es llamado por SimpleNft para validar
    // si este contrato (NFTSupportAndInmediateTransfer) está capacitado
    // para recibir NFTs
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        //selector == hash( onERC721Received(address,address,uint256,bytes) )
        // si se retorna el selector, el contrato de NFTs dirá que sí se puede enviar el NFT
        // Aquí 'msg.sender' es el contrato SimpleNft
        // Antes de la siguiente linea, el dueño del NFT es NFTSupportAndInmediateTransfer
        ISimpleNft(msg.sender).safeTransferFrom(
            address(this),
            nftReceiver,
            tokenId
        );
        return IERC721Receiver.onERC721Received.selector;
    }
}
