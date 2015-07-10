import Quick
import Nimble
@testable import pblock

class NSManagedObject_pblockSpec: QuickSpec {
  override func spec() {
    describe("pblock extensions to NSManagedObject") {
      let managedObjectContext = self.createInMemoryCoreDataCtx()

      it("should initialize the correct class") {
        let source = RuleSource(inContext: managedObjectContext)
        expect(source).to(beAnInstanceOf(RuleSource))
        expect(source.managedObjectContext).notTo(beNil())
        expect(source.entity.name).notTo(beNil())

        let rule = Rule(inContext: managedObjectContext)
        expect(rule).to(beAnInstanceOf(Rule))
        expect(rule.entity.name).notTo(beNil())
      }
    }
  }
}
