import SwiftUI

/// Unified bottom sheet styling used across the app.
/// - Uses medium and large detents.
/// - Shows drag indicator.
/// - Applies rounded corners and dark background when available (iOS 17+).
/// - Falls back to setting the content background color on iOS 16.
struct BottomSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(Color("backgroundblack"))
        } else if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                // iOS 16 does not support presentationBackground/cornerRadius
                // Set the sheet content background instead
                .background(Color("backgroundblack"))
        } else {
            content
        }
    }
}

extension View {
    /// Apply the app-wide bottom sheet style.
    func bottomSheetStyle() -> some View {
        modifier(BottomSheetModifier())
    }

    /// Emoji-specific bottom sheet style: lock to large detent and ignore keyboard safe area
    /// so the sheet doesn't resize/bounce when the emoji keyboard appears/disappears.
    func emojiBottomSheetStyle() -> some View {
        modifier(EmojiBottomSheetModifier())
    }
}

/// Bottom sheet style tailored for the emoji picker.
/// Locks to a single, large detent and ignores the keyboard safe area to keep transitions smooth.
private struct EmojiBottomSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(Color("backgroundblack"))
                .ignoresSafeArea(.keyboard)
        } else if #available(iOS 16.0, *) {
            content
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .background(Color("backgroundblack"))
        } else {
            content
        }
    }
}
