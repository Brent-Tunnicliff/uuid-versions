// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

final class MockDateService: DateService, @unchecked Sendable {
    private let lock = NSLock()

    private var _fractionNanosecondsValue: UInt16
    var fractionNanosecondsValue: UInt16 {
        get { lock.withLock { _fractionNanosecondsValue } }
        set { lock.withLock { _fractionNanosecondsValue = newValue } }
    }

    private var _nowValue: Date
    var nowValue: Date {
        get { lock.withLock { _nowValue } }
        set { lock.withLock { _nowValue = newValue } }
    }

    convenience init() {
        // Example date from [Appendix A. Test Vectors](https://www.rfc-editor.org/rfc/rfc9562#name-test-vectors).
        let exampleDate = "2022-02-22T19:22:22Z"
        guard let date = ISO8601DateFormatter().date(from: exampleDate) else {
            preconditionFailure("Unable to convert to date: \(exampleDate)")
        }

        self.init(nowValue: date)
    }

    init(
        fractionNanosecondsValue: UInt16 = 0,
        nowValue: Date,
    ) {
        self._fractionNanosecondsValue = fractionNanosecondsValue
        self._nowValue = nowValue
    }

    func now() -> Date {
        nowValue
    }

    func fractionNanoseconds() -> UInt16 {
        fractionNanosecondsValue
    }
}
