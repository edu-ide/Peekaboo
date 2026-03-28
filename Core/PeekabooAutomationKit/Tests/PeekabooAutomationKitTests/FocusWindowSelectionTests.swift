import CoreGraphics
import Testing
@testable import PeekabooAutomationKit

struct FocusWindowSelectionTests {
    @Test
    func `focus click point targets title-bar area near top center`() {
        let point = focusClickPoint(for: CGRect(x: 283, y: 46, width: 443, height: 616))
        #expect(point.x == 504.5)
        #expect(point.y >= 58)
        #expect(point.y <= 70)
    }

    @Test
    func `frontmost window order helper checks first entry only`() {
        #expect(isTargetFrontmostInWindowOrder([33077, 32252], targetWindowID: 33077) == true)
        #expect(isTargetFrontmostInWindowOrder([33077, 32252], targetWindowID: 32252) == false)
        #expect(isTargetFrontmostInWindowOrder([], targetWindowID: 33077) == false)
    }

    @Test
    func `window focus verification accepts app level focused ids when AXMain is stale`() {
        #expect(
            shouldTreatWindowAsFocused(
                targetWindowID: 33077,
                windowIsMain: false,
                windowIsFocused: true,
                windowIsMinimized: false,
                appFocusedWindowID: nil,
                appMainWindowID: nil
            ) == true
        )
        #expect(
            shouldTreatWindowAsFocused(
                targetWindowID: 33077,
                windowIsMain: false,
                windowIsFocused: false,
                windowIsMinimized: false,
                appFocusedWindowID: 33077,
                appMainWindowID: nil
            ) == true
        )
        #expect(
            shouldTreatWindowAsFocused(
                targetWindowID: 33077,
                windowIsMain: false,
                windowIsFocused: false,
                windowIsMinimized: false,
                appFocusedWindowID: nil,
                appMainWindowID: 33077
            ) == true
        )
        #expect(
            shouldTreatWindowAsFocused(
                targetWindowID: 33077,
                windowIsMain: false,
                windowIsFocused: false,
                windowIsMinimized: false,
                appFocusedWindowID: 32252,
                appMainWindowID: 32252
            ) == false
        )
        #expect(
            shouldTreatWindowAsFocused(
                targetWindowID: 33077,
                windowIsMain: false,
                windowIsFocused: false,
                windowIsMinimized: true,
                appFocusedWindowID: 33077,
                appMainWindowID: 33077
            ) == false
        )
    }

    @Test
    func `focused window selection prefers AX focused window id over list order`() {
        let windows = [
            makeServiceWindowInfo(windowID: 32252, title: "카카오톡", isMainWindow: true, index: 0),
            makeServiceWindowInfo(windowID: 33077, title: "권능 형", isMainWindow: false, index: 1),
        ]

        let resolved = selectFocusedWindowInfo(
            windows,
            focusedWindowID: 33077,
            mainWindowID: nil
        )

        #expect(resolved?.windowID == 33077)
    }

    @Test
    func `focused window selection falls back to main id then main flag then first`() {
        let windows = [
            makeServiceWindowInfo(windowID: 32252, title: "카카오톡", isMainWindow: false, index: 0),
            makeServiceWindowInfo(windowID: 33077, title: "권능 형", isMainWindow: true, index: 1),
        ]

        #expect(selectFocusedWindowInfo(windows, focusedWindowID: nil, mainWindowID: 33077)?.windowID == 33077)
        #expect(selectFocusedWindowInfo(windows, focusedWindowID: nil, mainWindowID: nil)?.windowID == 33077)
        let empty: [ServiceWindowInfo] = []
        #expect(selectFocusedWindowInfo(empty, focusedWindowID: nil, mainWindowID: nil) == nil)

        let noMainFlag = [
            makeServiceWindowInfo(windowID: 1, title: "one", isMainWindow: false, index: 0),
            makeServiceWindowInfo(windowID: 2, title: "two", isMainWindow: false, index: 1),
        ]
        #expect(selectFocusedWindowInfo(noMainFlag, focusedWindowID: nil, mainWindowID: nil)?.windowID == 1)
    }
}

private func makeServiceWindowInfo(
    windowID: Int,
    title: String,
    isMainWindow: Bool,
    index: Int
) -> ServiceWindowInfo {
    ServiceWindowInfo(
        windowID: windowID,
        title: title,
        bounds: CGRect(x: 0, y: 0, width: 400, height: 300),
        isMinimized: false,
        isMainWindow: isMainWindow,
        windowLevel: 0,
        alpha: 1,
        index: index,
        spaceID: 1,
        spaceName: "",
        screenIndex: 0,
        screenName: "Built-in Display",
        layer: 0,
        isOnScreen: true,
        sharingState: .readOnly,
        isExcludedFromWindowsMenu: false
    )
}
