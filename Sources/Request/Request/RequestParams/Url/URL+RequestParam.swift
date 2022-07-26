import Foundation

extension Foundation.URL: RequestParam {
    public func buildParam(_ request: inout URLRequest) {
        request.url = self
    }
}
