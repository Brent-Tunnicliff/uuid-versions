// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import InternalHelpers
import Testing

#if canImport(Darwin)
    import Foundation
#else
    import FoundationEssentials
#endif

struct SystemDateServiceTests {
    // Sanity test that the now value is returning around now-ish.
    @Test
    func now() {
        let startDate = Date()
        let dateService = SystemDateService.shared
        let result = dateService.now
        #expect(result >= startDate)
        #expect(result <= Date())
    }
}
