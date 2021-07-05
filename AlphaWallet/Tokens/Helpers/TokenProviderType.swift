//
//  TokenProviderType.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 09.06.2021.
//

import UIKit
import PromiseKit

protocol TokenProviderType: class {
    func delete(hiddenContract contract: AlphaWallet.Address)
    func addImportedTokenPromise(forContract contract: AlphaWallet.Address, server: RPCServer, onlyIfThereIsABalance: Bool) -> Promise<TokenObject>
    func fetchContractData(for address: AlphaWallet.Address, completion: @escaping (ContractData) -> Void)
    func addToken(for contract: AlphaWallet.Address, server: RPCServer, onlyIfThereIsABalance: Bool, completion: @escaping (TokenObject?) -> Void)
}

extension TokenProviderType {
    func addToken(for contract: AlphaWallet.Address, server: RPCServer, completion: @escaping (TokenObject?) -> Void) {
        addToken(for: contract, server: server, onlyIfThereIsABalance: false, completion: completion)
    }

    func addImportedTokenPromise(forContract contract: AlphaWallet.Address, server: RPCServer) -> Promise<TokenObject> {
        addImportedTokenPromise(forContract: contract, server: server, onlyIfThereIsABalance: false)
    }
}

class TokenProvider: TokenProviderType {
    private let storage: TokensDataStore
    private let assetDefinitionStore: AssetDefinitionStore

    init(storage: TokensDataStore, assetDefinitionStore: AssetDefinitionStore) {
        self.storage = storage
        self.assetDefinitionStore = assetDefinitionStore
    }

    func delete(hiddenContract contract: AlphaWallet.Address) {
        guard let hiddenContract = storage.hiddenContracts.first(where: { contract.sameContract(as: $0.contract) }) else { return }
        //TODO we need to make sure it's all uppercase?
        storage.delete(hiddenContracts: [hiddenContract])
    }

    func addImportedTokenPromise(forContract contract: AlphaWallet.Address, server: RPCServer, onlyIfThereIsABalance: Bool = false) -> Promise<TokenObject> {
        struct ImportTokenError: Error { }

        return Promise<TokenObject> { seal in
            delete(hiddenContract: contract)
            addToken(for: contract, server: server, onlyIfThereIsABalance: onlyIfThereIsABalance) { tokenObject in
//                    guard let strongSelf = self else { return }
                //strongSelf.delegate?.tokensDidChange(inCoordinator: strongSelf)

                if let tokenObject = tokenObject {
                    seal.fulfill(tokenObject)
                } else {
                    seal.reject(ImportTokenError())
                }
            }
        }
    }

    func fetchContractData(for address: AlphaWallet.Address, completion: @escaping (ContractData) -> Void) {
        fetchContractDataFor(address: address, storage: storage, assetDefinitionStore: assetDefinitionStore, completion: completion)
    }

    func addToken(for contract: AlphaWallet.Address, server: RPCServer, onlyIfThereIsABalance: Bool = false, completion: @escaping (TokenObject?) -> Void) {
        fetchContractData(for: contract) { [weak self] data in
            guard let strongSelf = self else { return }
            switch data {
            case .name, .symbol, .balance, .decimals:
                break
            case .nonFungibleTokenComplete(let name, let symbol, let balance, let tokenType):
                guard !onlyIfThereIsABalance || (onlyIfThereIsABalance && !balance.isEmpty) else { break }
                let token = ERCToken(
                        contract: contract,
                        server: server,
                        name: name,
                        symbol: symbol,
                        decimals: 0,
                        type: tokenType,
                        balance: balance
                )
                let value = strongSelf.storage.addCustom(token: token)
                completion(value)
            case .fungibleTokenComplete(let name, let symbol, let decimals):
                //We re-use the existing balance value to avoid the Wallets tab showing that token (if it already exist) as balance = 0 momentarily
                let value = strongSelf.storage.enabledObject.first(where: { $0.contractAddress == contract })?.value ?? "0"
                guard !onlyIfThereIsABalance || (onlyIfThereIsABalance && !(value != "0")) else { break }
                let token = TokenObject(
                        contract: contract,
                        server: server,
                        name: name,
                        symbol: symbol,
                        decimals: Int(decimals),
                        value: value,
                        type: .erc20
                )
                let value2 = strongSelf.storage.add(tokens: [token])[0]
                completion(value2)
            case .delegateTokenComplete:
                strongSelf.storage.add(delegateContracts: [DelegateContract(contractAddress: contract, server: server)])
                completion(.none)
            case .failed(let networkReachable):
                if let networkReachable = networkReachable, networkReachable {
                    strongSelf.storage.add(deadContracts: [DeletedContract(contractAddress: contract, server: server)])
                }
                completion(.none)
            }
        }
    }

}
