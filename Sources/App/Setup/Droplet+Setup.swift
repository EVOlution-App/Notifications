@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        
        //try App.loadFixtures()
    }
}
