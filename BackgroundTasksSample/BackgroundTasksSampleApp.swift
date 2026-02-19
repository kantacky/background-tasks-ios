//
//  BackgroundTasksSampleApp.swift
//  BackgroundTasksSample
//
//  Created by Kanta Oikawa on 2026/02/19.
//

import BackgroundTasks
import SwiftUI

@main
struct BackgroundTasksSampleApp: App {
    private let backgroundTaskIdentifier = "com.kantacky.BackgroundTasksSample.refresh"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await requestNotificationAuthorization()
                    scheduleAppRefresh()
                }
        }
        .backgroundTask(.appRefresh(backgroundTaskIdentifier)) {
            await notify()
            await scheduleAppRefresh()
        }
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled app refresh successfully")
        } catch {
            print("Failed to schedule app refresh: \(error)")
        }
    }

    private func notify() async {
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.body = "Message"
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Notified successfully")
        } catch {
            print("Failed to notify: \(error)")
        }
    }

    private func requestNotificationAuthorization() async {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            print(error)
        }
    }
}
