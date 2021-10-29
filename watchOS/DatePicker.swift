import SwiftUI
import Dynamic

fileprivate let now = Date()
fileprivate let calendar = Calendar.current
fileprivate let thisYear = calendar.component(.year, from: now)

/// A control for the inputting of date and time values.
struct DatePicker: View {
  /// Styles that determine the appearance of a date picker.
  enum Mode {
    /// Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
    case time
    
    /// Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
    case date
    
    /// Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
    case dateAndTime
  }
  
  var label: LocalizedStringKey?
  
  // TODO: wire selection up
  @Binding var selection: Date
  
  /// The style that the date picker is using for its layout.
  var mode: Mode = .dateAndTime
  
  /// The minimum date that a date picker can show.
  var minimumDate: Date?
  
  /// The maximum date that a date picker can show.
  var maximumDate: Date?
  
  /// Whether to display month before day. (MM DD YYYY vs. DD MM YYYY)
  var showsMonthBeforeDay: Bool
  
  /// A callback that will be invoked when the operation has succeeded.
  var onCompletion: ((Date) -> Void)?
  
  @State private var pickerViewIsPresented = false
  
  public init(
    _ label: LocalizedStringKey,
    selection: Binding<Date>,
    mode: Mode? = nil,
    minimumDate: Date? = nil,
    maximumDate: Date? = nil,
    showsMonthBeforeDay: Bool = true,
    onCompletion: ((Date) -> Void)? = nil
  ) {
    self.label = label
    _selection = selection
    if let value = mode { self.mode = value }
    self.minimumDate = minimumDate
    self.maximumDate = maximumDate
    self.showsMonthBeforeDay = showsMonthBeforeDay
    self.onCompletion = onCompletion
  }
  
  var body: some View {
    Button(action: { pickerViewIsPresented = true }) {
      VStack(alignment: .leading) {
        if let label = label {
          Text(label)
        }
        
        Text(DateFormatter.localizedString(from: selection, dateStyle: .medium, timeStyle: .short))
          .font(label != nil ? .footnote : .body)
          .foregroundStyle(label != nil ? .secondary : .primary)
      }
    }
    .fullScreenCover(isPresented: $pickerViewIsPresented) {
      NavigationView {
        DatePickerView(
          mode: mode,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          showsMonthBeforeDay: showsMonthBeforeDay,
          onCompletion: onCompletion
        )
      }
    }
  }
}

struct DatePickerView: View {
  var mode: DatePicker.Mode = .dateAndTime
  var minimumDate: Date?
  var maximumDate: Date?
  var showsMonthBeforeDay: Bool = true
  var onCompletion: ((Date) -> Void)?
  
  @State private var year = thisYear
  // TODO: select lower day if month’s upper bound day range is less than selection’s day
  @State private var month = calendar.component(.month, from: now)
  @State private var day = calendar.component(.day, from: now)
  
  @Environment(\.dismiss) private var dismiss
  
  private func _onCompletion(_ date: Date) {
    dismiss()
    onCompletion?(date)
  }
  
  private var selection: Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day))!
  }
  
  private var yearRange: Range<Int> {
    var lowerBound = (thisYear - 100)
    var upperBound = (thisYear + 100 + 1)
    if let minimumDate = minimumDate {
      lowerBound = calendar.component(.year, from: minimumDate)
    }
    if let maximumDate = maximumDate {
      upperBound = calendar.component(.year, from: maximumDate)
    }
    return lowerBound..<upperBound
  }
  
  private var monthSymbols: [EnumeratedSequence<[String]>.Element] {
    Array(calendar.shortMonthSymbols.enumerated())
  }
  
  private var dayRange: Range<Int> {
    calendar.range(of: .day, in: .month, for: selection)!
  }
  
  var body: some View {
    if mode == .time {
      TimePickerView(mode: mode, onCompletion: _onCompletion)
    } else {
      datePicker
    }
  }
  
  var datePicker: some View {
    VStack(spacing: 10) {
      HStack {
        if showsMonthBeforeDay {
          monthPicker
          dayPicker
        } else {
          dayPicker
          monthPicker
        }
        yearPicker
      }
      .pickerStyle(.wheel)
      .textCase(.uppercase)
      
      Group {
        if mode == .dateAndTime {
          // Button("Continue", action: { timePickerIsPresented = true })
          NavigationLink("Continue") {
            TimePickerView(date: selection, mode: mode, onCompletion: _onCompletion)
              // TODO: make this navigation title white somehow
              .navigationTitle(DateFormatter.localizedString(from: selection, dateStyle: .medium, timeStyle: .none))
              .navigationBarTitleDisplayMode(.inline)
          }
        } else {
          Button("Done", action: { _onCompletion(selection) })
        }
      }
      .buttonStyle(.borderedProminent)
      .foregroundStyle(.background)
      .tint(.green)
    }
    .statusBarTime(hidden: true)
    //    .toolbar {
    //      ToolbarItem(placement: .confirmationAction) {
    //        if mode != .dateAndTime {
    //          Button("Done", action: {})
    //        }
    //      }
    //    }
    //    .fullScreenCover(isPresented: $timePickerIsPresented) {
    //      TimePicker(mode: mode)
    //    }
  }
  
  var yearPicker: some View {
    Picker("Year", selection: $year) {
      ForEach(yearRange) { year in
        Text(String(year))
          .tag(year)
      }
    }
    // .focusable()
  }
  
  var monthPicker: some View {
    Picker("Month", selection: $month) {
      ForEach(monthSymbols, id: \.offset) { month, symbol in
        Text(symbol)
          .tag(month)
      }
    }
    // .focusable()
  }
  
  var dayPicker: some View {
    Picker("Day", selection: $day) {
      ForEach(dayRange) { day in
        Text(String(day))
          .tag(day)
      }
    }
    .id([month, year].map(String.init).joined(separator: "."))
    // .focusable()
  }
}

struct TimePickerView: View {
  @State var date: Date = now
  var mode: DatePicker.Mode = .time
  var selectionDotSize: Double = 4
  var selectionDotColor: Color = .accentColor
  var onCompletion: ((Date) -> Void)?
  
  private enum HourPeriod { case am, pm }
  @State private var hourPeriod = HourPeriod.pm
  
  private enum Component { case hour, minute }
  @State private var focusedComponent = Component.minute
  
  @State private var hour = 0
  @State private var minute = 0

  @Environment(\.dismiss) private var dismiss
  
  public init(
    date: Date = now,
    mode: DatePicker.Mode = .time,
    selectionDotSize: Double = 4,
    selectionDotColor: Color = .accentColor,
    onCompletion: ((Date) -> Void)? = nil
  ) {
    self.date = date
    self.mode = mode
    self.selectionDotSize = selectionDotSize
    self.selectionDotColor = selectionDotColor
    self.onCompletion = onCompletion
    hour = calendar.component(.hour, from: date)
    minute = calendar.component(.minute, from: date)
  }

//  @State private var hour = calendar.component(.hour, from: date)
//  @State private var minute = calendar.component(.minute, from: date)
  
//  private var minute: Binding<Double> {
//    Binding {
//      Double(calendar.component(.minute, from: date))
//    } set: { newValue in
//      calendar.date(bySetting: .minute, value: Int(newValue), of: date)
//    }
//  }

  private var focusedValue: Binding<Double> {
    Binding {
      switch focusedComponent {
      case .hour: return Double(hour)
      case .minute: return Double(minute)
      }
    } set: { newValue in
      switch focusedComponent {
      case .hour: return hour = Int(abs(newValue)) % 12
      case .minute: return minute = Int(abs(newValue)) % 60
      }
    }
  }
  
  private var focusedValueMultiple: Double {
    switch focusedComponent {
    case .hour: return 12
    case .minute: return 60
    }
  }
  
  private var selection: Date {
    calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
  }
  
  private func _onCompletion() {
//    dismiss()
    onCompletion?(selection)
    onCompletion?(selection)
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      clockFace
      pickerButtons
//      cancelAcceptButtons
    }
    .drawingGroup(opaque: true)
    .edgesIgnoringSafeArea(.all)
    .focusable()
    .statusBarTime(hidden: true)
    .digitalCrownRotation(
      focusedValue,
      //      .constant(0.0),
      from: -Double.infinity,
      through: Double.infinity,
      by: nil,
      sensitivity: .low,
      isContinuous: true,
      isHapticFeedbackEnabled: false
    )
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Done", action: _onCompletion)
      }
    }
    // TODO: wrapping
    //    .onChange(of: $value) { newValue in
    //      if newValue.
    //    }
  }
  
  var clockFace: some View {
    GeometryReader { geometry in
      ForEach(0..<60) { index in
        let isMultipleOfFive = index % 5 == 0
        // TODO: move to method
        Rectangle()
          .size(width: isMultipleOfFive ? 1.5 : 1, height: isMultipleOfFive ? 3 : 7)
        // .offset(x: -10 / 2, y: -40 / 2)
          .offset(y: geometry.size.height / 3)
          .offset(y: isMultipleOfFive ? 4 : 0)
          .rotation(.degrees(Double(index) * 360 / 60), anchor: UnitPoint.init(x: 0, y: 0))
          .fill(isMultipleOfFive ? .primary : .tertiary)
          .position(x: geometry.size.width, y: geometry.size.height)
      }
      
      clockFaceLabels(with: geometry)
      
      selectionDot(with: geometry)
    }
    .padding(-10)
    .offset(y: 10)
  }
  
  func selectionDot(with geometry: GeometryProxy) -> some View {
    Circle()
      .size(width: selectionDotSize, height: selectionDotSize)
      .offset(x: -selectionDotSize / 2, y: -selectionDotSize / 2)
      .offset(y: -geometry.size.height / 3)
      .offset(y: -6)
      .rotation(.degrees(focusedValue.wrappedValue * 360 / focusedValueMultiple), anchor: UnitPoint.init(x: 0, y: 0))
    // .rotation(.degrees(focusedValue.wrappedValue * 360 / focusedValueMultiple))
      .fill(Color.accentColor)
      .animation(.spring(), value: focusedValue.wrappedValue)
      .position(x: geometry.size.width, y: geometry.size.height)
  }
  
  func clockFaceLabels(with geometry: GeometryProxy) -> some View {
    switch focusedComponent {
    case .hour:
      return ForEach(0..<12) { index in
        clockFaceLabel(String(Int(index + 1)), at: index, with: geometry)
      }
    case .minute:
      return ForEach(0..<12) { index in
        clockFaceLabel(String(format: "%02d", Int(index * 5)), at: index, with: geometry)
      }
    }
  }
  
  func clockFaceLabel(_ string: String, at index: Int, with geometry: GeometryProxy) -> some View {
    ZStack {
      Text(string)
        .rotationEffect(.degrees(-Double(index) * 360 / 12), anchor: .center)
        .padding(.bottom, geometry.size.height * 0.58)
    }
    .rotationEffect(.degrees(Double(index) * 360 / 12), anchor: .center)
    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
  }
  
  //  func clockFaceDash(at index: Int, with geometry: GeometryProxy) -> some View {
  //    let isMultipleOfFive = index % 5 == 0
  //
  //    Group {
  //      switch focusedComponent {
  //      case .hour:
  //        EmptyView()
  //      case .minute:
  //        if isMultipleOfFive {
  //          ZStack {
  //            Text(String(format: "%02d", Int(index)))
  //              .font(.body.weight(.medium))
  //              .rotationEffect(.degrees(-Double(index) * 360 / 60), anchor: .center)
  //              .padding(.bottom, geometry.size.height * 0.58)
  //          }
  //          .rotationEffect(.degrees(Double(i) * 360 / 60), anchor: .center)
  //          .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
  //        }
  //      }
  //    }
  //  }
  
  var pickerButtons: some View {
    VStack {
      Spacer()
      
      Button(calendar.amSymbol, action: { hourPeriod = .am })
        .buttonStyle(.timePickerAMPM(isHighlighted: hourPeriod == .am))
      
      HStack {
        Button(String(hour + 1), action: { focusedComponent = .hour })
          .buttonStyle(.timePickerComponent(isFocused: focusedComponent == .hour))
        
        Text(":")
          .padding(.bottom)
        
        Button(String(format: "%02d", minute), action: { focusedComponent = .minute })
          .buttonStyle(.timePickerComponent(isFocused: focusedComponent == .minute))
      }
      .font(.title2)
      
      Button(calendar.pmSymbol, action: { hourPeriod = .pm })
        .buttonStyle(.timePickerAMPM(isHighlighted: hourPeriod == .pm))
      
      Spacer()
    }
//    .offset(y: -15)
  }
  
  var cancelAcceptButtons: some View {
    HStack {
      Button(action: { dismiss() }) {
        if mode == .dateAndTime {
          Image(systemName: "chevron.backward")
        } else {
          Image(systemName: "xmark")
        }
      }
      .buttonStyle(.circular())
      
      Spacer()
      
      Button(action: _onCompletion) {
        Image(systemName: "checkmark")
      }
      .buttonStyle(.circular(.green))
    }
    .padding(.horizontal, 9)
    .padding(.bottom)
  }
}

fileprivate extension ButtonStyle where Self == TimePickerComponentButtonStyle {
  static func timePickerComponent(isFocused: Bool = false) -> Self { .init(isFocused: isFocused) }
}

fileprivate struct TimePickerComponentButtonStyle: ButtonStyle {
  var isFocused: Bool
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(width: 43, height: 48)
      .overlay {
        RoundedRectangle(cornerRadius: 9)
          .stroke(isFocused ? .green : .timePickerComponentButtonBorder, lineWidth: 1.5)
      }
  }
}

fileprivate extension Color {
  static var timePickerComponentButtonBorder: Self { Color(white: 0.298) }
}

fileprivate extension ButtonStyle where Self == TimePickerAMPMButtonStyle {
  static func timePickerAMPM(isHighlighted: Bool = false) -> Self { .init(isHighlighted: isHighlighted) }
}

fileprivate struct TimePickerAMPMButtonStyle: ButtonStyle {
  var isHighlighted: Bool
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(width: 24.5, height: 16)
      .opacity(configuration.isPressed ? 0.5 : isHighlighted ? 1 : 0.8)
      .font(.footnote.weight(isHighlighted ? .semibold : .regular))
      .foregroundColor(isHighlighted ? .black : .accentColor)
      .background {
        RoundedRectangle(cornerRadius: 3)
          .fill(isHighlighted ? Color.accentColor : Color.clear)
      }
  }
}

struct DatePicker_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TimePickerView(mode: .time)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: {})
          }
        }
    }
    .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
    .previewDisplayName("Mode: Time")

    NavigationView {
      DatePickerView(mode: .date)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: {})
          }
        }
    }
    .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
    .previewDisplayName("Mode: Date")

    NavigationView {
      DatePickerView(mode: .dateAndTime)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: {})
          }
        }
    }
    .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
    .previewDisplayName("Mode: Date & Time (Step 1)")

    NavigationView {
      NavigationLink(isActive: .constant(true)) {
        TimePickerView(mode: .dateAndTime)
      } label: {
        EmptyView()
      }
      .opacity(0)
    }
    .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
    .previewDisplayName("Mode: Date & Time (Step 2)")
  }
}
