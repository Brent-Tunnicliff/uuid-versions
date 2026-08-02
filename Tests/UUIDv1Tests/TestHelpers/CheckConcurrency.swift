// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import UUIDv1

/// Runs a large number of task groups to stress test manually implemented concurrency locks.
func checkConcurrency(
    numberOfConcurrentGroups: Int = 10_000,
    action: @Sendable @escaping () async -> Void
) async {
    precondition(numberOfConcurrentGroups > 0)
    await withTaskGroup { group in
        let lock = Lock()
        nonisolated(unsafe) var start = false

        for _ in 0..<numberOfConcurrentGroups {
            group.addTask { @concurrent in
                // Make all groups wait for the start before triggering action.
                while lock.withLock({ start }) == false {
                    // Back to the queue with ya!
                    await Task.yield()
                }

                await action()
            }
        }

        lock.withLock {
            start = true
        }

        await group.waitForAll()
    }
}
