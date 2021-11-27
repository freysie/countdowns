import CoreData
import UserNotifications
#if os(macOS)
import AppKit
#else
import ClockKit
#endif

struct PersistenceController {
  static let shared = Self()
  
  let container = NSPersistentContainer(name: "Countdowns")
  
  init(inMemory: Bool = false) {
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })

#if os(macOS)
    Task.detached(priority: .userInitiated) { [self] in
      let countdowns = try! container.viewContext.fetch(Countdown.fetchRequest()) as [Countdown]
      for countdown in countdowns {
        if countdown.shownInMenuBar {
          print(countdown)
          await MainActor.run {
            _ = NSStatusBar.system.addStatusItem(for: countdown)
          }
        }
      }
    }
#endif
    
    NotificationCenter.default.addObserver(
      forName: .NSManagedObjectContextObjectsDidChange,
      object: container.viewContext,
      queue: nil
    ) { notification in
      if let insertedCountdowns = notification.userInfo?[NSInsertedObjectsKey] as? Set<Countdown> {
#if os(watchOS)
        CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
#endif
        
        Task.detached(priority: .userInitiated) {
          for countdown in insertedCountdowns {
            print(countdown)
            try! await UNUserNotificationCenter.current().addRequest(for: countdown)
          }
        }
      }
      
      if let updatedCountdowns = notification.userInfo?[NSUpdatedObjectsKey] as? Set<Countdown> {
#if os(watchOS)
        // TOOD: optimize to only reload timeline for changed countdowns
        for complication in CLKComplicationServer.sharedInstance().activeComplications ?? [] {
          CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
        }
#endif
        
#if os(macOS)
        for countdown in updatedCountdowns {
          if countdown.shownInMenuBar {
            NSStatusBar.system.addStatusItem(for: countdown)
          } else {
            NSStatusBar.system.removeStatusItem(for: countdown)
          }
        }
#endif
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
          withIdentifiers: updatedCountdowns.map { $0.uuidString }
        )
        
        Task.detached(priority: .userInitiated) {
          for countdown in updatedCountdowns {
            print(countdown)
            try! await UNUserNotificationCenter.current().addRequest(for: countdown)
          }
        }
      }
      
      if let deletedCountdowns = notification.userInfo?[NSDeletedObjectsKey] as? Set<Countdown> {
#if os(watchOS)
        CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
#endif
        
        print(deletedCountdowns)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
          withIdentifiers: deletedCountdowns.map { $0.uuidString }
        )
      }
    }
  }
}
