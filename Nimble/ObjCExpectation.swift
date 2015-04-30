internal struct ObjCMatcherWrapper : Matcher {
    let matcher: NMBMatcher

    func matches(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.matches(
            ({ actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }

    func doesNotMatch(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.doesNotMatch(
            ({ actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }
}

// Equivalent to Expectation, but for Nimble's Objective-C interface
public class NMBExpectation : NSObject {
    let _actualBlock: () -> NSObject!
    var _negative: Bool
    let _file: String
    let _line: UInt
    var _timeout: NSTimeInterval = 1.0

    public init(actualBlock: () -> NSObject!, negative: Bool, file: String, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    private var expectValue: Expectation<NSObject> {
        return expect(file: _file, line: _line){
            self._actualBlock() as NSObject?
        }
    }

    public var withTimeout: (NSTimeInterval) -> NMBExpectation {
        return ({ timeout in self._timeout = timeout
            return self
        })
    }

    public var to: (NMBMatcher) -> Void {
        return ({ matcher in
            self.expectValue.to(ObjCMatcherWrapper(matcher: matcher))
        })
    }

    public var toNot: (NMBMatcher) -> Void {
        return ({ matcher in
            self.expectValue.toNot(
                ObjCMatcherWrapper(matcher: matcher)
            )
        })
    }

    public var notTo: (NMBMatcher) -> Void { return toNot }

    public var toEventually: (NMBMatcher) -> Void {
        return ({ matcher in
            self.expectValue.toEventually(
                ObjCMatcherWrapper(matcher: matcher),
                timeout: self._timeout
            )
        })
    }

    public var toEventuallyNot: (NMBMatcher) -> Void {
        return ({ matcher in
            self.expectValue.toEventuallyNot(
                ObjCMatcherWrapper(matcher: matcher),
                timeout: self._timeout
            )
        })
    }
}
