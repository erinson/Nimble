import Foundation

typealias MatcherBlock = (actualExpression: Expression<NSObject>, failureMessage: FailureMessage, location: SourceLocation) -> Bool
typealias FullMatcherBlock = (actualExpression: Expression<NSObject>, failureMessage: FailureMessage, location: SourceLocation, shouldNotMatch: Bool) -> Bool
@objc public class NMBObjCMatcher : NMBMatcher {
    let _match: MatcherBlock
    let _doesNotMatch: MatcherBlock
    let canMatchNil: Bool

    init(canMatchNil: Bool, matcher: MatcherBlock, notMatcher: MatcherBlock) {
        self.canMatchNil = canMatchNil
        self._match = matcher
        self._doesNotMatch = notMatcher
    }

    convenience init(matcher: MatcherBlock) {
        self.init(canMatchNil: true, matcher: matcher)
    }

    convenience init(canMatchNil: Bool, matcher: MatcherBlock) {
        self.init(canMatchNil: canMatchNil, matcher: matcher, notMatcher: ({ actualExpression, failureMessage, location in
            return !matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location)
        }))
    }

    convenience init(matcher: FullMatcherBlock) {
        self.init(canMatchNil: true, matcher: matcher)
    }

    convenience init(canMatchNil: Bool, matcher: FullMatcherBlock) {
        self.init(canMatchNil: canMatchNil, matcher: ({ actualExpression, failureMessage, location in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location, shouldNotMatch: false)
        }), notMatcher: ({ actualExpression, failureMessage, location in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location, shouldNotMatch: true)
        }))
    }

    private func canMatch(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        if !canMatchNil && actualExpression.evaluate() == nil {
            failureMessage.postfixActual = " (use beNil() to match nils)"
            return false
        }
        return true
    }

    public func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let expr = Expression(expression: actualBlock, location: location)
        let result = _match(
            actualExpression: expr,
            failureMessage: failureMessage,
            location: location)
        if self.canMatch(Expression(expression: actualBlock, location: location), failureMessage: failureMessage) {
            return result
        } else {
            return false
        }
    }

    public func doesNotMatch(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let expr = Expression(expression: actualBlock, location: location)
        let result = _doesNotMatch(
            actualExpression: expr,
            failureMessage: failureMessage,
            location: location)
        if self.canMatch(Expression(expression: actualBlock, location: location), failureMessage: failureMessage) {
            return result
        } else {
            return false
        }
    }
}

