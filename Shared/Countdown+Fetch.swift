import CoreData

extension Countdown {
//  class func fetch(objectID: String) throws -> Self? {
//    let container = PersistenceController.shared.container
//    let url = URL(string: objectID)!
//    guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else { return nil }
//    return container.viewContext.object(with: id) as? Self
//  }
  
  class func fetch(id: UUID) throws -> Self? {
    let request = fetchRequest()
    request.fetchLimit = 1
    request.predicate = .init(format: "id = %@", id as CVarArg)
    let objects = try PersistenceController.shared.container.viewContext.fetch(request) as! [Self]
    return objects.first
  }
}
