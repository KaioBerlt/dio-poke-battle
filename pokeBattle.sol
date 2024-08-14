// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PokeDIO is ERC721 {
    struct Pokemon {
        string name;
        uint256 level;
        string img;
    }

    Pokemon[] public pokemons;
    address public gameOwner;
    mapping(uint256 => address) public pokemonOwners;

    constructor() ERC721("PokeDIO", "PKD") {
        gameOwner = msg.sender;
    }

    modifier onlyOwnerOf(uint256 _pokemonId) {
        require(
            pokemonOwners[_pokemonId] == msg.sender,
            "Apenas o dono pode batalhar com este Pokemon"
        );
        _;
    }

    function battle(
        uint256 _attackingPokemon,
        uint256 _defendingPokemon
    ) public onlyOwnerOf(_attackingPokemon) {
        require(
            _attackingPokemon < pokemons.length,
            "Pokemon atacante invalido"
        );
        require(
            _defendingPokemon < pokemons.length,
            "Pokemon defensor invalido"
        );
        require(
            _attackingPokemon != _defendingPokemon,
            "O Pokemon atacante e defensor nao podem ser o mesmo"
        );

        Pokemon storage attacker = pokemons[_attackingPokemon];
        Pokemon storage defender = pokemons[_defendingPokemon];

        Pokemon memory tempAttacker = attacker;
        Pokemon memory tempDefender = defender;

        if (tempAttacker.level >= tempDefender.level) {
            tempAttacker.level += 2;
            tempDefender.level += 1;
        } else {
            tempAttacker.level += 1;
            tempDefender.level += 2;
        }

        pokemons[_attackingPokemon] = tempAttacker;
        pokemons[_defendingPokemon] = tempDefender;
    }

    function createNewPokemon(
        string memory _name,
        address _to,
        string memory _img
    ) public {
        require(
            msg.sender == gameOwner,
            "Apenas o dono do jogo pode criar novos Pokemons"
        );
        uint256 id = pokemons.length;
        pokemons.push(Pokemon(_name, 1, _img));
        _safeMint(_to, id);
        pokemonOwners[id] = _to;
        return;
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
        return pokemonOwners[_tokenId];
    }
}
