import CoreData
import UserNotifications

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
    
    NotificationCenter.default.addObserver(
      forName: .NSManagedObjectContextObjectsDidChange,
      object: container.viewContext,
      queue: nil
    ) { notification in
//      let insertedObjects = notification.userInfo![NSInsertedObjectsKey]
//      let updatedObjects = notification.userInfo![NSUpdatedObjectsKey]
      
      if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<Countdown> {
        print(deletedObjects)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
          withIdentifiers: deletedObjects.map { $0.uuidString }
        )
      }
    }
  }
}
