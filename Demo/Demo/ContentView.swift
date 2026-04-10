import SwiftUI
import RecurrenceKit

struct ContentView: View {
    @State private var selectedDates: Set<DateComponents> = []

    private var sortedDates: [Date] {
        let calendar = Calendar.current
        return selectedDates
            .compactMap { calendar.date(from: $0) }
            .sorted()
    }

    private var patternDescription: String {
        let dates = sortedDates
        guard dates.count >= 2 else {
            return dates.isEmpty ? "Select dates" : "Select more dates"
        }
        let pattern = RecurrencePattern.predict(from: dates)
        return pattern.description
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                patternLabel
                calendarView
            }
            .navigationTitle("RecurrenceKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        selectedDates.removeAll()
                    }
                    .disabled(selectedDates.isEmpty)
                }
            }
        }
    }

    private var patternLabel: some View {
        Text(patternDescription)
            .font(sortedDates.count >= 2 ? .headline : .subheadline)
            .foregroundStyle(sortedDates.count >= 2 ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .animation(.default, value: patternDescription)
    }

    private var calendarView: some View {
        MultiDateCalendarView(selectedDates: $selectedDates)
    }
}

#Preview {
    ContentView()
}
