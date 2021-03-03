import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(QuickPaySDKAcquirersTests.allTests),
        testCase(QuickPaySDKPaymentTests.allTests),
        testCase(QuickPaySDKSubscriptionTests.allTests)
    ]
}
#endif
