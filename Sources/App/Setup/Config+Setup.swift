import FluentProvider
import MongoProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MongoProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(App.self)
        preparations.append(Device.self)
        preparations.append(Tag.self)
        preparations.append(Track.self)
        preparations.append(User.self)
        preparations.append(Track.self)
        preparations.append(Notification.self)
    }
}
