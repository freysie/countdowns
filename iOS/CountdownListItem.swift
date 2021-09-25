import SwiftUI

struct CountdownListItem: View {
  var countdown: Countdown
  
  @State private var editSheetIsPresented = false
  
  @Environment(\.editMode) private var editMode
  
  @AppStorage("showsTargetInListView") private var showsTarget = false
  @AppStorage("showsDisclosureIndicatorsInListView") private var showsDisclosureIndicators = false
  
  var body: some View {
    Button(action: { editSheetIsPresented = true }) {
      HStack {
        TimelineView(.countdown) { schedule in
          VStack(alignment: .leading) {
            Text(CountdownFormatter.string(for: countdown, relativeTo: schedule.date))
              .font(.system(size: 48, weight: .light)) // size: 56?
              .monospacedDigit()
              .lineLimit(1)
              .minimumScaleFactor(0.5)
              .foregroundStyle(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .primary : .tertiary)
            
            Text(
              countdown.label != nil && !countdown.label!.isEmpty
              ? countdown.label!
              : NSLocalizedString("Countdown", comment: "")
            )
              .font(.subheadline)
              .foregroundColor(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .primary : .accentColor)
            
            if showsTarget, let target = countdown.target {
//              if let source = countdown.source {
//                Text(DateFormatter.localizedString(from: source, dateStyle: .long, timeStyle: .short))
//                  .font(.subheadline)
//                  .foregroundStyle(.secondary)
//              }
              
              Text(DateFormatter.localizedString(from: target, dateStyle: .long, timeStyle: .short))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
                .padding(.top, -10) // FIXME: why is this necessary‽
            }
          }
          .padding(.bottom, 7)
        }
        
        if showsDisclosureIndicators && !editMode!.wrappedValue.isEditing {
          Spacer()

          NavigationLink.empty
        }
      }
    }
    .sheet(isPresented: $editSheetIsPresented) {
      NavigationView {
        EditForm(countdown: countdown)
      }
    }
  }
}
