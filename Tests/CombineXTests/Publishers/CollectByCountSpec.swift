import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class CollectByCountSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values by collection
            it("should relay values by collection") {
                let pub = PassthroughSubject<Int, CustomError>()
                let sub = makeCustomSubscriber([Int].self, CustomError.self, .unlimited)
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events).to(equal([
                    .value([0, 1]),
                    .value([2, 3]),
                    .value([4]),
                    .completion(.finished)
                ]))
            }
            
            // MARK: 1.2 should relay as many values as demand
            it("should relay as many values as demand") {
                let pub = PassthroughSubject<Int, CustomError>()
                let sub = CustomSubscriber<[Int], CustomError>(receiveSubscription: { (s) in
                    s.request(.max(1))
                }, receiveValue: { v in
                    v == [0, 1] ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events).to(equal(
                    [.value([0, 1]), .value([2, 3]), .completion(.finished)]
                ))
            }
        }
    }
}