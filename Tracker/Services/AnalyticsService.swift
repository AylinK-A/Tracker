import Foundation
import AppMetricaCore

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

final class AnalyticsService {

    static let shared = AnalyticsService()
    private init() {}

    /// Единая точка отправки событий по ТЗ: event / screen / item(optional)
    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item {
            params["item"] = item.rawValue
        }

        AppMetrica.reportEvent(name: "ui_event", parameters: params, onFailure: { error in
            print("❌ AppMetrica report failed:", error.localizedDescription)
        })

        #if DEBUG
        print("📊 AppMetrica:", params)
        #endif
    }
}

