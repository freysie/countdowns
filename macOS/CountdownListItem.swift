import SwiftUI

struct CountdownListItem: View {
  @ObservedObject var countdown: Countdown
  
  @State private var editSheetIsPresented = false
  @State private var deleteConfirmationIsPresented = false
  
  @AppStorage("showsTargetInListView") private var showsTarget = false
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    NavigationLink {
      CountdownProgressView(countdown: countdown)
        // .focusable()
        .frame(minWidth: 500)
        .padding()
        .padding()
        .offset(x: 0, y: -38/2)
    } label: {
      HStack {
        TimelineView(.countdown) { schedule in
          VStack(alignment: .leading) {
            Text(CountdownFormatter.string(for: countdown, relativeTo: schedule.date))
              .font(.title.weight(.light))
              .monospacedDigit()
              .lineLimit(1)
            // .minimumScaleFactor(0.5)
              .foregroundStyle(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .primary : .tertiary)
            
            Text(countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: ""))
              .font(.headline)
              .foregroundColor(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .secondary : .accentColor)
            
            if showsTarget, let target = countdown.target {
              //              if let source = countdown.source {
              //                Text(DateFormatter.localizedString(from: source, dateStyle: .long, timeStyle: .short))
              //                  .font(.subheadline)
              //                  .foregroundStyle(.secondary)
              //              }
              
              Text(DateFormatter.localizedString(from: target, dateStyle: .long, timeStyle: .short))
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
                .padding(.top, -10) // FIXME: why is this necessary‽
            }
          }
        }
      }
    }
    .sheet(isPresented: $editSheetIsPresented) {
      EditForm(countdown: countdown)
    }
    .confirmationDialog(
      "Are you sure you want to delete this countdown?",
      isPresented: $deleteConfirmationIsPresented
    ) {
      Button("Delete Countdown", role: .destructive, action: delete)
      Button("Cancel", role: .cancel, action: { deleteConfirmationIsPresented = false })
    }
    .contextMenu {
      Button("Edit Countdown", action: { editSheetIsPresented = true })

      Toggle("Show in Menu Bar", isOn: $countdown.shownInMenuBar)
        .onSubmit { try! viewContext.save() }

      Divider()

      Button("Delete", action: { deleteConfirmationIsPresented = true })
    }
  }
  
  private func delete() {
    viewContext.delete(countdown)
  }
}
