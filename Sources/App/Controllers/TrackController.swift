import Vapor
import HTTP

final class TrackController {
    func register(_ request: Request) throws -> ResponseRepresentable {
        try AuthorizationProvider.checkAPIKey(request)
        
        guard let json = request.json else {
            throw Abort.badRequest
        }
        
        // User
        guard let ckID = json["user"]?.string else {
            throw Abort(.badRequest, reason: "user is required")
        }
        
        guard let user = try User.get(by: ckID) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        // Notification
        guard let notificationID = json["notification"]?.string else {
            throw Abort(.badRequest, reason: "notification is required")
        }
        
        guard let notification = try Notification.get(by: notificationID) else {
            throw Abort(.notFound, reason: "Notification not found")
        }
        
        // Source Track
        guard let sourceID = json["source"]?.string else {
            throw Abort(.badRequest, reason: "source is required")
        }
        
        guard let source = SourceTrack(rawValue: sourceID) else {
            throw Abort(.badRequest, reason: "invalid source: '\(sourceID)'. Sources available: 'ios', 'macos', 'safari', 'chrome'")
        }

        if let userID = user.id?.string ,  try Track.getBy(notification: notificationID, user: userID, source: sourceID) != nil {
            throw Abort(.conflict, reason: "You've already tracked your notification.")
        }
        
        // Save Track
        let track = Track(
            notification: try notification.assertExists(),
            user: try user.assertExists(),
            source: source.rawValue
        )
        
        do {
            try track.save()
        }
        catch {
            throw Abort(.internalServerError)
        }
        
        
        return Response(status: .created)
    }
}

extension TrackController: EmptyInitializable {}
