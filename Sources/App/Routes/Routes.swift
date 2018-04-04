import Vapor

extension Droplet {
    func setupRoutes() throws {
        let deviceController = DeviceController()

        get("device", ":vendor", handler: deviceController.show)
        post("device", handler: deviceController.store)
    }
}
