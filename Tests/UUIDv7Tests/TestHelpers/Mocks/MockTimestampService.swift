// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

@testable import UUIDv7

final class MockTimestampService: TimestampService, @unchecked Sendable {
    private let lock = Lock()
    private var timestampValue: Timestamp

    init(timestampValue: Timestamp) {
        self.timestampValue = timestampValue
    }

    func getTimestamp() -> Timestamp {
        lock.withLock { timestampValue }
    }

    func incrementMockTimestamp() {
        lock.withLock {
            timestampValue = Timestamp(
                milliseconds: timestampValue.milliseconds + 1,
                fraction: timestampValue.fraction
            )
        }
    }

    func setMock(
        milliseconds: UInt64? = nil,
        fraction: UInt16? = nil
    ) {
        lock.withLock {
            timestampValue = Timestamp(
                milliseconds: milliseconds ?? timestampValue.milliseconds,
                fraction: fraction ?? timestampValue.fraction
            )
        }
    }

    func setMock(timestamp: Timestamp) {
        lock.withLock {
            timestampValue = timestamp
        }
    }
}

extension TimestampService where Self == MockTimestampService {
    static func mock(
        milliseconds: UInt64 = 0,
        fraction: UInt16 = 0
    ) -> Self {
        Self(
            timestampValue: Timestamp(
                milliseconds: milliseconds,
                fraction: fraction
            )
        )
    }
}
