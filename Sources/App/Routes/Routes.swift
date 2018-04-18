import Vapor

extension Droplet {
    func setupRoutes() throws {

        // Devices
        let deviceController = DeviceController(drop: self)
        get("device", ":token", handler: deviceController.show)
        post("device", handler: deviceController.store)
        
        // Tags
        let tagController = TagController()
        get("tags", handler: tagController.list)
        
        // User
        let userController = UserController()
        put("user", ":id", handler: userController.updateTags)
        get("user", ":id", handler: userController.show)
        
        // Track
        let trackController = TrackController()
        post("track", handler: trackController.register)
    }
}
