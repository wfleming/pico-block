import Quick
import CoreData

extension QuickSpec {
  func createInMemoryCoreDataCtx() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!

    let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    try! storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)

    let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = storeCoordinator

    return managedObjectContext
  }
}