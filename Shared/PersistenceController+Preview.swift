import CoreData

extension PersistenceController {
  static var preview: Self = {
    guard !isTakingScreenshots else { return screenshots }
    
    let controller = Self(inMemory: true)
    let viewContext = controller.container.viewContext
    
//    do {
//      let item = Countdown(context: viewContext)
//      item.id = UUID()
//      item.target = Date().addingTimeInterval(5)
//      item.label = "Testing, testing, 1, 2, 3…"
//    }
    
//    do {
//      let item = Countdown(context: viewContext)
//      item.id = UUID(uuidString: "E960F154-236B-44BD-AF9D-70F7FBEDF029")!
//      item.target = Calendar.current.date(bySetting: .hour, value: 5, of: Calendar.current.date(bySetting: .weekday, value: 5, of: Date())!)!
////      item.target = try! Date("2021-09-24T15:00:00Z", strategy: .iso8601)
//      item.label = "Friday, 5 pm"
//      item.repeat = .weekly
//    }
    
    do {
      let item = Countdown(context: viewContext)
      item.id = UUID(uuidString: "D5CD3ACB-7616-4893-854A-2B36841F7F00")!
      item.source = Date().addingTimeInterval(-2443332 / 2)
      item.target = Date().addingTimeInterval(2443332)
      item.label = "Movie Night"
      item.repeat = .monthly
    }
    
    do {
      let item = Countdown(context: viewContext)
      item.id = UUID(uuidString: "53C293BC-CB3C-47DB-8E24-B5E187861060")!
      item.target = try! Date("2022-12-24T00:00:00Z", strategy: .iso8601)
      item.label = "☃️🎄🎉"
      item.repeat = .yearly
    }
    
//    do {
//      let item = Countdown(context: viewContext)
//      item.id = UUID(uuidString: "24FC8544-5AA8-4179-9D32-8BF97963AE5A")!
//      item.target = try! Date("2021-12-31T23:00:00Z", strategy: .iso8601)
//      item.label = "New Year 🥳"
//      item.repeat = .yearly
//    }
    
//    for i in 1..<100 {
//      let item = Countdown(context: viewContext)
//      item.id = UUID()
//      item.target = try! Date("2021-12-31T23:00:00Z", strategy: .iso8601)
//      item.label = "STRESS TEST \(i) 😵‍💫"
//    }
    
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    return controller
  }()

  static var screenshots: Self = {
    let controller = Self(inMemory: true)
    let viewContext = controller.container.viewContext
    
    do {
      let item = Countdown(context: viewContext)
      item.id = UUID(uuidString: "D5CD3ACB-7616-4893-854A-2B36841F7F00")!
      item.source = previewDate.addingTimeInterval(-2443332 / 2)
      item.target = previewDate.addingTimeInterval(2443332)
      item.label = "Movie Night"
      item.tone = .none
    }
    
    do {
      let item = Countdown(context: viewContext)
      item.id = UUID(uuidString: "53C293BC-CB3C-47DB-8E24-B5E187861060")!
      item.target = try! Date("2021-12-24T11:00:00Z", strategy: .iso8601)
      item.label = "☃️🎄🎉"
      item.repeat = .yearly
    }
    
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
    return controller
  }()
}
