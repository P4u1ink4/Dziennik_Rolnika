
import SwiftUI

struct Cow: Identifiable {
    let id = UUID()
    let identificationNumber: String
    let birthDate: Date
    let breed: String
    let lactation: String
    var events: [Event]
    var image: Data?
}

struct Event: Identifiable {
    let id = UUID()
    let type: EventType
    let date: Date
    let notes: String
}

enum EventType: String {
    case calving = "Wycielenie"
    case estrus = "Ruja"
    case dryingOff = "Zasuszenie"
    case insemination = "Inseminacja"
    case calfCheck = "Badanie cielności"
    case inne = "Inne"

    static let allTypes: [EventType] = [.calving, .estrus, .dryingOff, .insemination, .calfCheck, .inne]
}


class CowManager: ObservableObject {
    @Published var cows: [Cow] = []
    private let cowsKey = "savedCowsKey"

    init() {
        loadCows()
    }


    func removeCow(id: UUID) {
        cows.removeAll { cow in
            cow.id == id
        }
        saveCows()
    }

    func addEvent(to cowID: UUID, event: Event) {
        if let cowIndex = cows.firstIndex(where: { $0.id == cowID }) {
            cows[cowIndex].events.append(event)
        }
        saveCows()
    }

    func removeEvent(from cowID: UUID, eventID: UUID) {
        if let cowIndex = cows.firstIndex(where: { $0.id == cowID }) {
            cows[cowIndex].events.removeAll { event in
                event.id == eventID
            }
        }
        saveCows()
    }
    
    func addCow(identificationNumber: String, birthDate: Date, breed: String, lactation: String, image: Data?) {
        cows.append(Cow(identificationNumber: identificationNumber, birthDate: birthDate, breed: breed, lactation: lactation, events: [], image: image))
        saveCows()
    }
    
    private func saveCows() {
        var serializedCows: [[String: Any]] = []
        
        for cow in cows {
            var serializedCow: [String: Any] = [
                "id": cow.id.uuidString,
                "identificationNumber": cow.identificationNumber,
                "birthDate": cow.birthDate,
                "breed": cow.breed,
                "lactation": cow.lactation,
                "events": []
            ]
            
            // Convert UIImage to Data before saving
            if let image = cow.image {
                serializedCow["image"] = image
            }
            
            for event in cow.events {
                let serializedEvent: [String: Any] = [
                    "id": event.id.uuidString,
                    "type": event.type.rawValue,
                    "date": event.date,
                    "notes": event.notes
                ]
                serializedCow["events"] = (serializedCow["events"] as? [[String: Any]] ?? []) + [serializedEvent]
            }
            
            serializedCows.append(serializedCow)
        }
        
        UserDefaults.standard.set(serializedCows, forKey: cowsKey)
    }


    private func loadCows() {
        if let savedCows = UserDefaults.standard.array(forKey: cowsKey) as? [[String: Any]] {
            var loadedCows: [Cow] = []
            
            for serializedCow in savedCows {
                if let cowIDString = serializedCow["id"] as? String,
                   let cowIdentificationNumber = serializedCow["identificationNumber"] as? String,
                   let cowBirthDate = serializedCow["birthDate"] as? Date,
                   let cowBreed = serializedCow["breed"] as? String,
                   let cowLactation = serializedCow["lactation"] as? String,
                   let cowImage = serializedCow["image"] as? Data,
                   let serializedEvents = serializedCow["events"] as? [[String: Any]] {
                   
                    var loadedEvents: [Event] = []
                    for serializedEvent in serializedEvents {
                        if let eventIDString = serializedEvent["id"] as? String,
                           let eventTypeString = serializedEvent["type"] as? String,
                           let eventDate = serializedEvent["date"] as? Date,
                           let eventNotes = serializedEvent["notes"] as? String,
                           let eventType = EventType(rawValue: eventTypeString) {
                            
                            _ = UUID(uuidString: eventIDString) ?? UUID()
                            let loadedEvent = Event( type: eventType, date: eventDate, notes: eventNotes)
                            loadedEvents.append(loadedEvent)
                        }
                    }
                    
                    _ = UUID(uuidString: cowIDString) ?? UUID()
                    let loadedCow = Cow( identificationNumber: cowIdentificationNumber, birthDate: cowBirthDate, breed: cowBreed, lactation: cowLactation, events: loadedEvents, image: cowImage)
                    loadedCows.append(loadedCow)
                }
            }
            
            cows = loadedCows
        }
    }

    
}

struct AddCowView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cowManager: CowManager

    @State private var birthDate = Date()
    @State private var breed: String = ""
    @State private var lactation: String = ""
    @State private var prefix1 = "P"
    @State private var prefix2 = "L"
    @State private var digit1 = ""
    @State private var digit2 = ""
    @State private var digit3 = ""
    @State private var digit4 = ""
    @State private var digit5 = ""
    @State private var digit6 = ""
    @State private var digit7 = ""
    @State private var digit8 = ""
    @State private var digit9 = ""
    @State private var digit10 = ""
    @State private var digit11 = ""
    @State private var digit12 = ""

    @State private var digits = ""
    
    @State private var drawing = Path()
    @State private var drawingColor: Color = .black
    @State private var savedImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informacje o krowie")) {
                    HStack {
                        Text("ID")
                        TextField("1", text: $prefix1)
                            .frame(width: 10)
                            .onChange(of: prefix1) { newValue in
                                if newValue.count > 1 {
                                    prefix1 = String(newValue.prefix(1))
                                }
                            }
                            .tag(1)
                        TextField("1", text: $prefix2)
                            .frame(width: 10)
                            .onChange(of: prefix2) { newValue in
                                if newValue.count > 1 {
                                    prefix2 = String(newValue.prefix(1))
                                }
                            }
                            .tag(1)
                        TextField("123456789101112", text: $digits )
                            .tracking(6.5)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 250)
                            .keyboardType(.numberPad)
                            .onChange(of: digits) { newValue in
                                if newValue.count >= 12 {
                                    digits = String(newValue.prefix(12))
                                    
                                   let indices = 0..<12
                                    for index in indices {
                                        let currentIndex = digits.index(digits.startIndex, offsetBy: index)
                                        
                                        let digit = String(digits[currentIndex])
                                        switch index {
                                        case 0: digit1 = digit
                                        case 1: digit2 = digit
                                        case 2: digit3 = digit
                                        case 3: digit4 = digit
                                        case 4: digit5 = digit
                                        case 5: digit6 = digit
                                        case 6: digit7 = digit
                                        case 7: digit8 = digit
                                        case 8: digit9 = digit
                                        case 9: digit10 = digit
                                        case 10: digit11 = digit
                                        case 11: digit12 = digit
                                        default: break
                                        }
                                    }
                                }
                            }
                    }
                    DatePicker("Data urodzenia", selection: $birthDate, displayedComponents: .date)
                    TextField("Rasa", text: $breed)
                    TextField("Laktacja", text: $lactation)
                }
                DrawableView(drawing: $drawing, drawingColor: $drawingColor)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let currentPoint = value.location
                            drawing.addLine(to: currentPoint)
                        }
                        .onEnded { _ in
                            drawing.move(to: .zero)
                        }
                    )
                Button("Dodaj krowę") {
                    if(!prefix1.isEmpty && !prefix2.isEmpty && !digit1.isEmpty && !digit2.isEmpty && !digit3.isEmpty && !digit4.isEmpty && !digit5.isEmpty && !digit6.isEmpty && !digit7.isEmpty && !digit8.isEmpty && !digit9.isEmpty && !digit10.isEmpty && !digit11.isEmpty && !digit12.isEmpty){
                            let identificationNumber = prefix1 + prefix2 + digit1 + digit2 + digit3 + digit4 + digit5 + digit6 + digit7 + digit8 + digit9 + digit10 + digit11 + digit12
                        cowManager.addCow(identificationNumber: identificationNumber, birthDate: birthDate, breed: breed, lactation: lactation, image: createImageFromDrawableView(drawing: $drawing, drawingColor: $drawingColor, cowImage: UIImage(imageLiteralResourceName: "cow")).pngData())
                                presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("Nowa krowa")
        }
    }
    func createImageFromDrawableView(drawing: Binding<Path>, drawingColor: Binding<Color>, cowImage: UIImage) -> UIImage {
        let targetSize = CGSize(width: 150, height: 150)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        
        // Draw the cow image
        cowImage.draw(in: CGRect(origin: .zero, size: targetSize))
        
        // Draw the drawing path
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(drawing.wrappedValue.cgPath)
        context?.setStrokeColor(drawingColor.wrappedValue.cgColor!)
        context?.setLineWidth(2)
        context?.strokePath()

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage ?? UIImage()
    }
}

struct DrawableView: View {
    @Binding var drawing: Path
    @Binding var drawingColor: Color
    @State private var currentPoint: CGPoint?
    @State private var lastPoint: CGPoint?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("cow")
                .resizable()
                .frame(width: 150,height: 150)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPoint = value.location
                            if let lastPoint = lastPoint, let currentPoint = currentPoint {
                                drawing.move(to: lastPoint)
                                drawing.addLine(to: currentPoint)
                            }
                            lastPoint = currentPoint
                        }
                        .onEnded { _ in
                            currentPoint = nil
                            lastPoint = nil
                        }
                )
            Path { path in
                path.addPath(drawing)
            }
            .stroke(drawingColor, lineWidth: 2)
        }
    }
}

struct Cows: View {
    @ObservedObject private var cowManager = CowManager()
    
    @State private var digit1 = ""
    @State private var digit2 = ""
    @State private var digit3 = ""
    @State private var digit4 = ""
    @State private var isAddingCowSheetPresented = false

    let characterLimit = 1
    
    var filteredCows: [Cow] {
        let inputDigits = digit1 + digit2 + digit3 + digit4

        if inputDigits.isEmpty {
            return cowManager.cows
        } else {
            return cowManager.cows.filter { cow in
                if !digit1.isEmpty{
                    let startIndex = cow.identificationNumber.index(cow.identificationNumber.startIndex, offsetBy: 9)
                    let digit1cow = cow.identificationNumber[startIndex]
                    if(String(digit1cow) != digit1){
                        return false
                    }
                }
                if !digit2.isEmpty{
                    let startIndex = cow.identificationNumber.index(cow.identificationNumber.startIndex, offsetBy: 10)
                    let digit2cow = cow.identificationNumber[startIndex]
                    if(String(digit2cow) != digit2){
                        return false
                    }
                }
                if !digit3.isEmpty{
                    let startIndex = cow.identificationNumber.index(cow.identificationNumber.startIndex, offsetBy: 11)
                    let digit3cow = cow.identificationNumber[startIndex]
                    if(String(digit3cow) != digit3){
                        return false
                    }
                }
                if !digit4.isEmpty{
                    let startIndex = cow.identificationNumber.index(cow.identificationNumber.startIndex, offsetBy: 12)
                    let digit4cow = cow.identificationNumber[startIndex]
                    if(String(digit4cow) != digit4){
                        return false
                    }
                }
                return true
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NumericTextField(placeholder: "1", text: $digit1, nextField: $digit2)
                    NumericTextField(placeholder: "2", text: $digit2, nextField: $digit3)
                    NumericTextField(placeholder: "3", text: $digit3, nextField: $digit4)
                    NumericTextField(placeholder: "4", text: $digit4, nextField: $digit4)
                    Button("Dodaj krowę") {
                        isAddingCowSheetPresented.toggle()
                    }
                    .padding()
                }
                List(filteredCows) { cow in
                    NavigationLink(destination: CowDetail(cow: cow, cowManager: cowManager)) {
                        HStack(spacing: 0) {
                            Text(cow.identificationNumber.dropLast(5))
                                .font(Font.system(size: 20))
                                .tracking(2)
                                .foregroundColor(.black)
                            Text(cow.identificationNumber.suffix(5).dropLast(1))
                                .font(Font.system(size: 23))
                                .tracking(2)
                                .foregroundColor(.red)
                            Text(cow.identificationNumber.suffix(1))
                                .tracking(2)
                                .font(Font.system(size:20))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .navigationTitle("Spis krów")
        }
        .sheet(isPresented: $isAddingCowSheetPresented, content: {
            AddCowView(cowManager: cowManager)
        })
    }
}

struct NumericTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var nextField: String
    
    var body: some View {
        TextField(placeholder, text: $text )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 40)
            .foregroundColor(.red)
            .keyboardType(.numberPad)
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}

struct EventNotesView: View {
    @Binding var isPresented: Bool
    @Binding var notes: String // Use the notes directly

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $notes) // Use notes directly
                    .padding()
                Spacer()
            }
            .navigationTitle("Custom Notes")
            .navigationBarItems(
                trailing:
                    Button("Save") {
                        // Save the custom notes to the appropriate data structure or UserDefaults
                        isPresented = false
                    }
            )
        }
    }
}

struct CowDetail: View {
    let cow: Cow
    let cowManager: CowManager

    @State private var newEventDate = Date()
    @State private var selectedEventType: EventType = .calving
    @State private var eventNotes = ""
    @State private var isEventNotesViewPresented = false

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("ID: ")
                    .font(.title)
                    .padding()
                    .tracking(2)
                Text(cow.identificationNumber.dropLast(5))
                    .tracking(2)
                    .font(.title)
                    .foregroundColor(.black)
                Text(cow.identificationNumber.suffix(5).dropLast(1))
                    .font(.title)
                    .tracking(2)
                    .foregroundColor(.red)
                Text(cow.identificationNumber.suffix(1))
                    .tracking(2)
                    .font(.title)
                    .foregroundColor(.black)
            }
            GeometryReader { geometry in
                HStack(spacing:50){
                    VStack{
                        Text("Data urodzenia:")
                            .font(.footnote)
                            .padding(.horizontal)
                            .scaledToFit()
                        Text(formattedDate(date:cow.birthDate))
                            .font(.footnote)
                            .padding(.horizontal)
                            .scaledToFit()
                        Text("Rasa: \(cow.breed)")
                            .font(.footnote)
                            .padding(.horizontal)
                            .scaledToFit()
                        Text("Laktacja: \(cow.lactation)")
                            .font(.footnote)
                            .padding(.horizontal)
                            .scaledToFit()
                    }
                    if let imageData = cow.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 150, height: 150)
                    } else {
                        Image("cow")
                            .resizable()
                            .frame(width: 150, height: 150)
                    }
                }
            }
            List(cow.events) { event in
                VStack(alignment: .leading) {
                    Text(event.type.rawValue)
                    Text(event.date.description)
                        .font(.caption)
                    Text(event.notes)
                        .font(.caption)
                }
            }

            DatePicker("Data", selection: $newEventDate, displayedComponents: .date)
                .padding(.horizontal)
            
            Picker(selection: $selectedEventType, label: Text("Zdarzenie")) {
                ForEach(EventType.allTypes, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type) // Ustawienie tagu na typ zdarzenia
                }
            }
            .pickerStyle(MenuPickerStyle()) // Ustawienie stylu pickera
            .padding(.horizontal)
            
            HStack{
                Button(action: {
                    isEventNotesViewPresented.toggle()
                }) {
                    Text("Add/Edit Notes")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isEventNotesViewPresented) {
                    EventNotesView(isPresented: $isEventNotesViewPresented, notes: $eventNotes)
                }

                Button("Dodaj wydarzenie") {
                    let newEvent = Event(type: selectedEventType, date: newEventDate, notes: eventNotes)
                    cowManager.addEvent(to: cow.id, event: newEvent)
                    newEventDate = Date()
                    selectedEventType = .calving
                    eventNotes = ""
                }
                .padding(.horizontal)
            }
            
            Button("Usuń krowę") {
                cowManager.removeCow(id: cow.id)
            }
            .foregroundColor(.red)
            .padding(5.0)
        }
        .navigationTitle("Informacje")
    }
    
    func formattedDate(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter.string(from: date)
        }
}

struct Cows_Previews: PreviewProvider {
    static var previews: some View {
        Cows()
    }
}


