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

    private var detected: Bool { sortedDates.count >= 2 }

    private var patternDescription: String {
        let dates = sortedDates
        guard dates.count >= 2 else {
            return dates.isEmpty
                ? "Tap dates to detect a pattern"
                : "Select at least one more date"
        }
        return RecurrencePattern.predict(from: dates).description
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    patternLabel
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    MultiDateCalendarView(selectedDates: $selectedDates)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("RecurrenceKit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        withAnimation { selectedDates.removeAll() }
                    }
                    .disabled(selectedDates.isEmpty)
                }
            }
        }
    }

    private var patternLabel: some View {
        Text(patternDescription)
            .font(detected ? .title3.weight(.semibold) : .subheadline)
            .foregroundStyle(detected ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
            .contentTransition(.numericText())
            .animation(.smooth, value: patternDescription)
    }
}

#Preview {
    ContentView()
}
