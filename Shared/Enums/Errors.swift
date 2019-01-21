// MARK - Errors

enum ProfileError: Error {
    case profileWithSameNameAlreadyExiest
}

enum AppError: Error {
    case cantGetAppName
}
