// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

actor Counter {
    private(set) var value: Int = 0

    func increment() {
        value += 1
    }
}
