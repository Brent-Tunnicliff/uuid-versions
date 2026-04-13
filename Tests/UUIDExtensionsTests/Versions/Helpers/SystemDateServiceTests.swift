// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing
@testable import UUIDExtensions

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

struct SystemDateServiceTests {
    private let date: Date
    private let dateService: SystemDateService
    private let mockClockWrapper = MockClockWrapper()

    init() throws {
        // ISO8601DateFormatter ignores sub-millisecond values.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        let date = try #require(formatter.date(from: "2023-01-01T12:34:56.1234567Z"))
        self.date = date
        self.dateService = SystemDateService(
            clockWrapper: mockClockWrapper,
            nowSource: { date }
        )
    }

    // Sanity test that the now function is returning the contents of the nowSource.
    @Test
    func nowReturnsSource() {
        #expect(dateService.now() == date)
    }

    // Example taken from [Section 6.2, method 3](https://www.rfc-editor.org/rfc/rfc9562#section-6.2).
    @Test
    func fractionNanoseconds() {
        mockClockWrapper.attosecondsComponent = 456_700_000_000_000
        #expect(dateService.fractionNanoseconds() == 1870)
    }
}

private final class MockClockWrapper: ClockWrapper, @unchecked Sendable {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    var durationSinceAnchor: Duration {
        lock.withLock {
            Duration(
                secondsComponent: _secondsComponent,
                attosecondsComponent: _attosecondsComponent
            )
        }
    }

    private let lock = NSLock()

    private var _secondsComponent: Int64 = 0
    var secondsComponent: Int64 {
        get { lock.withLock { _secondsComponent } }
        set { lock.withLock { _secondsComponent = newValue } }
    }

    private var _attosecondsComponent: Int64 = 0
    var attosecondsComponent: Int64 {
        get { lock.withLock { _attosecondsComponent } }
        set { lock.withLock { _attosecondsComponent = newValue } }
    }
}
