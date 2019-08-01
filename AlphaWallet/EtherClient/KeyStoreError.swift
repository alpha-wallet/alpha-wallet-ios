// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public enum KeystoreError: LocalizedError {
    case failedToDeleteAccount
    case failedToDecryptKey
    case failedToImport(Error)
    case duplicateAccount
    case failedToSignTransaction
    case failedToCreateWallet
    case failedToImportPrivateKey
    case failedToParseJSON
    case accountNotFound
    case failedToSignMessage
    case failedToExportPrivateKey
    case failedToExportSeed
    case accountMayNeedImportingAgainOrEnablePasscode

    public var errorDescription: String? {
        switch self {
        case .failedToDeleteAccount:
            return R.string.localizable.accountsDeleteErrorFailedToDeleteAccount()
        case .failedToDecryptKey:
            return R.string.localizable.accountsDeleteErrorFailedToDecryptKey()
        case .failedToImport(let error):
            return error.localizedDescription
        case .duplicateAccount:
            return R.string.localizable.accountsDeleteErrorDuplicateAccount()
        case .failedToSignTransaction:
            return R.string.localizable.accountsDeleteErrorFailedToSignTransaction()
        case .failedToCreateWallet:
            return R.string.localizable.accountsDeleteErrorFailedToCreateWallet()
        case .failedToImportPrivateKey:
            return R.string.localizable.accountsDeleteErrorFailedToImportPrivateKey()
        case .failedToParseJSON:
            return R.string.localizable.accountsDeleteErrorFailedToParseJSON()
        case .accountNotFound:
            return R.string.localizable.accountsDeleteErrorAccountNotFound()
        case .failedToSignMessage:
            return R.string.localizable.accountsDeleteErrorFailedToSignMessage()
        case .failedToExportPrivateKey:
            return R.string.localizable.accountsDeleteErrorFailedToExportPrivateKey()
        case .failedToExportSeed:
            return R.string.localizable.accountsDeleteErrorFailedToExportSeed()
        case .accountMayNeedImportingAgainOrEnablePasscode:
            return R.string.localizable.keystoreAccessKeyNeedImportOrPasscode()
        }
    }
}
