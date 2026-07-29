// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if os(WASI)
    let isWasm = true
#else
    let isWasm = false
#endif
