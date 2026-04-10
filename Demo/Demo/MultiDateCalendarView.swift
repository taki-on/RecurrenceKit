import SwiftUI

struct MultiDateCalendarView: UIViewRepresentable {
    @Binding var selectedDates: Set<DateComponents>

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = .current
        calendarView.availableDateRange = DateInterval(
            start: .distantPast,
            end: .distantFuture
        )

        let selection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        calendarView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        guard let selection = uiView.selectionBehavior as? UICalendarSelectionMultiDate else {
            return
        }
        let current = Set(selection.selectedDates)
        if current != selectedDates {
            selection.setSelectedDates(Array(selectedDates), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedDates: $selectedDates)
    }

    class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate {
        @Binding var selectedDates: Set<DateComponents>

        init(selectedDates: Binding<Set<DateComponents>>) {
            _selectedDates = selectedDates
        }

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            didSelectDate dateComponents: DateComponents
        ) {
            selectedDates.insert(dateComponents)
        }

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            didDeselectDate dateComponents: DateComponents
        ) {
            selectedDates.remove(dateComponents)
        }
    }
}
