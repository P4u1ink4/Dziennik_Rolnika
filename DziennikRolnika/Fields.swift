

import SwiftUI
import MapKit

struct Fields: View {
    @ObservedObject var viewModel = FieldViewModel()
    @State private var selectedCategoryFilters: Set<String> = []
    @State private var selectedField: Field?
    @State private var showAddFieldSheet = false
    @State private var isCategoryFilterSheetPresented = false
    @State private var isFilterApplied = false
    @State private var allCategories: Set<String> = []
    @ObservedObject var colorManager = ColorManager()
    
    var filteredFields: [Field] {
        if selectedCategoryFilters.isEmpty {
            return viewModel.fields
        } else {
            return viewModel.fields.filter { selectedCategoryFilters.contains($0.category) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Filtruj") {
                    isCategoryFilterSheetPresented.toggle()
                }
                .padding()
                .sheet(isPresented: $isCategoryFilterSheetPresented, content: {
                    CategoryFilterSheet(selectedCategoryFilters: $selectedCategoryFilters, allCategories: loadAllCategories(), isFilterApplied: $isFilterApplied, isCategoryFilterSheetPresented: $isCategoryFilterSheetPresented)
                })
                
                MapView(fields: filteredFields, selectedField: $selectedField, selectedCategoryFilters: selectedCategoryFilters, color:  colorManager.selectedColor)
                    .frame(height: 500)
                
                
                VStack {
                    ColorPicker("", selection:  $colorManager.selectedColor)
                }
                .frame(maxWidth: 50, maxHeight: 50)
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                showAddFieldSheet.toggle()
            }) {
                Image(systemName: "plus")
            }
            )
            .sheet(isPresented: $showAddFieldSheet, content: {
                AddFieldView(allCategories: $allCategories, onAddField: { newField in
                    viewModel.addField(newField)
                    allCategories.insert(newField.category)
                    updateAllCategories()
                })
            })
        }
        .onAppear {
            colorManager.loadSelectedColor()
        }
        .onDisappear {
            colorManager.saveSelectedColor()
        }
    }
    
    private func updateAllCategories() {
        var categories = Set<String>()
        for field in viewModel.fields {
            categories.insert(field.category)
        }
        allCategories = categories
        saveAllCategories()
    }
    private func saveAllCategories() {
        let categoriesArray = Array(allCategories)
        UserDefaults.standard.set(categoriesArray, forKey: "allCategoriesKey")
    }

    private func loadAllCategories() -> Set<String> {
        if let categoriesArray = UserDefaults.standard.array(forKey: "allCategoriesKey") as? [String] {
            return Set(categoriesArray)
        }
        return Set<String>()
    }
}

class ColorManager: ObservableObject {
    
    @Published var selectedColor: Color = .black
    
    init() {
        loadSelectedColor()
    }
    
    func saveSelectedColor() {
            UserDefaults.standard.set(selectedColor.description, forKey: "colorKey")
        }
        
    func loadSelectedColor() {
        if let colorString = UserDefaults.standard.string(forKey: "colorKey"),
            let loadedColor = colorFromString(colorString) {
            selectedColor = loadedColor
        }
    }
    
    func colorFromString(_ colorString: String) -> Color? {
        let components = colorString.split(separator: " ")
        if components.count == 4,
            let red = Double(components[1]),
            let green = Double(components[2]),
            let blue = Double(components[3]),
            let opacity = Double(components[4]) {
            return Color(
                .sRGB,
                red: red,
                green: green,
                blue: blue,
                opacity: opacity
            )
        }
        return nil
    }
}


class FieldViewModel: ObservableObject {
    @Published var fields: [Field] = []

    private let fieldsKey = "savedFieldsKey"

    init() {
        loadFields()
    }

    func addField(_ field: Field) {
        fields.append(field)
        saveFields()
    }

    private func saveFields() {
        var serializedFields: [[String: Any]] = []
        
        for field in fields {
            let serializedField: [String: Any] = [
                "id": field.id.uuidString,
                "latitude": field.location.latitude,
                "longitude": field.location.longitude,
                "category": field.category,
                "history": field.history,
                "spanLatitudeDelta": field.span.latitudeDelta,
                "spanLongitudeDelta": field.span.longitudeDelta,
                "drawnPath": encodeDrawnPath(field.drawnPath)
            ]
            serializedFields.append(serializedField)
        }
        
        UserDefaults.standard.set(serializedFields, forKey: fieldsKey)
    }
    
    private func encodeDrawnPath(_ drawnPath: [CGPoint]) -> [[String: CGFloat]] {
        return drawnPath.map { point in
            return ["x": point.x, "y": point.y]
        }
    }
    
    private func decodeDrawnPath(_ drawnPathData: [[String: CGFloat]]) -> [CGPoint] {
        return drawnPathData.map { dict in
            return CGPoint(x: dict["x"] ?? 0, y: dict["y"] ?? 0)
        }
    }

    private func loadFields() {
        if let savedFields = UserDefaults.standard.array(forKey: fieldsKey) as? [[String: Any]] {
            var loadedFields: [Field] = []
            
            for serializedField in savedFields {
                if let fieldIDString = serializedField["id"] as? String,
                   let latitude = serializedField["latitude"] as? CLLocationDegrees,
                   let longitude = serializedField["longitude"] as? CLLocationDegrees,
                   let category = serializedField["category"] as? String,
                   let history = serializedField["history"] as? String,
                   let spanLatitudeDelta = serializedField["spanLatitudeDelta"] as? CLLocationDegrees,
                   let spanLongitudeDelta = serializedField["spanLongitudeDelta"] as? CLLocationDegrees,
                   let drawnPathData = serializedField["drawnPath"] as? [[String: CGFloat]]
                {
                    
                    let fieldID = UUID(uuidString: fieldIDString) ?? UUID()
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let span = MKCoordinateSpan(latitudeDelta: spanLatitudeDelta, longitudeDelta: spanLongitudeDelta)
                    let drawnPath = decodeDrawnPath(drawnPathData)
                    let loadedField = Field(location: location, span: span, category: category, history: history, drawnPath: drawnPath)
                    loadedFields.append(loadedField)
                }
            }
            
            fields = loadedFields
        }
    }
}


struct MapView: View {
    var fields: [Field]
    @Binding var selectedField: Field?
    var selectedCategoryFilters: Set<String>
    var color: Color
    
    @State private var isShowingDetails = false
    
    
    var body: some View {
        Map(coordinateRegion: regionForFields(), showsUserLocation: false, userTrackingMode: nil, annotationItems: annotationItems) { field in
            MapAnnotation(coordinate: field.location) {
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        selectedField = field
                        isShowingDetails.toggle()
                    }
            }
        }
        .frame(height: 500)
        .sheet(item: $selectedField) { field in
            FieldDetailsView(field: field)
        }
    }
    
    private var annotationItems: [Field] {
        return fields.filter { selectedCategoryFilters.isEmpty || selectedCategoryFilters.contains($0.category) }
    }
    
    private func regionForFields() -> Binding<MKCoordinateRegion> {
        let initialCoordinate = CLLocationCoordinate2D(latitude: 52.4064, longitude: 16.9252) // Poznań coordinates
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        return Binding(
            get: { MKCoordinateRegion(center: initialCoordinate, span: span) },
            set: { _ in }
        )
    }
}

struct FieldDetailsView: View {
    @Environment(\.dismiss) var dismiss
    var field: Field
    
    var body: some View {
        VStack {
            Text("\(field.category)")
            TextEditor(text: .constant(field.history))
                .disabled(true)
                .padding()
            
            DrawnPathView(field: field)
        }
        .padding()
    }
}

struct DrawnPathView: View {
    var field: Field

    var body: some View {
        ZStack {
            Map(coordinateRegion: regionForLocation(field: field), showsUserLocation: false)
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)
                .disabled(true)
                .overlay(
                    GeometryReader { geometry in
                        Path { path in
                            if !field.drawnPath.isEmpty {
                                let start = field.drawnPath[0]
                                path.move(to: start)

                                for point in field.drawnPath.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                        }
                        .stroke(Color.red, lineWidth: 5)
                    }
                )
                
        }
    }

    private func regionForLocation(field: Field) -> Binding<MKCoordinateRegion> {
        return Binding(
            get: {         MKCoordinateRegion(center: field.location, span: field.span) },
            set: { _ in }
        )
    }
}

struct CategoryFilterSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedCategoryFilters: Set<String>
    var allCategories: Set<String>
    @Binding var isFilterApplied: Bool
    @Binding var isCategoryFilterSheetPresented: Bool
    
    var body: some View {
        VStack {
            List(Array(allCategories).sorted(), id: \.self) { category in
                Button(action: {
                    toggleCategory(category)
                }) {
                    HStack {
                        Image(systemName: selectedCategoryFilters.contains(category) ? "checkmark.square.fill" : "square")
                        Text(category)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            
            Button("Zastosuj") {
                isFilterApplied = true
                isCategoryFilterSheetPresented = false
            }
            .padding()
        }
    }
    
    private func toggleCategory(_ category: String) {
        if selectedCategoryFilters.contains(category) {
            selectedCategoryFilters.remove(category)
        } else {
            selectedCategoryFilters.insert(category)
        }
    }
}

struct Field: Identifiable {
    let id = UUID()
    var location: CLLocationCoordinate2D
    var span: MKCoordinateSpan
    var category: String
    var history: String
    var drawnPath: [CGPoint] = []

    mutating func addPointToPath(_ point: CGPoint) {
        drawnPath.append(point)
    }
}

struct AddFieldView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.4064, longitude: 16.9252),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var category: String = ""
    @State private var oneyearago: String = ""
    @State private var twoyearago: String = ""
    @State private var threeyearago: String = ""
    @State private var different: String = ""
    @State private var history: String = ""
    @Binding var allCategories: Set<String>
    
    @State private var drawnPoints: [CGPoint] = []
    @State private var isDrawingMode = false
    
    var onAddField: (Field) -> Void
    
    var centerCoordinate: CLLocationCoordinate2D {
        return mapRegion.center
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $mapRegion, showsUserLocation: true)
                .gesture(
                    isDrawingMode ?
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                let location = value.location
                                if CGRect(origin: .zero, size: UIScreen.main.bounds.size).contains(location) {
                                    drawnPoints.append(location)
                                }
                            }
                        : nil
                )
                .overlay(
                    GeometryReader { geometry in
                        Path { path in
                            if isDrawingMode, !drawnPoints.isEmpty {
                                let start = drawnPoints[0]
                                path.move(to: start)

                                for point in drawnPoints.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                        }
                        .stroke(Color.red, lineWidth: 5)
                    }
                )
                .overlay(
                    GeometryReader { geometry in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 5, height: 5)
                            .opacity(0.8)
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                    }
                )
                .frame(width: 400, height: 400)

            Toggle("Tryb rysowania", isOn: $isDrawingMode)
                .padding()

            VStack(spacing: -4){
                TextField("Kategoria", text: $category)
                    .padding()
                
                TextField("Rok temu: ", text: $oneyearago)
                    .padding()
                
                TextField("Dwa lata temu: ", text: $twoyearago)
                    .padding()
                
                TextField("Trzy lata temu: ", text: $threeyearago)
                    .padding()
                
                TextField("Inne: ", text: $different)
                    .padding()
            }
            
            Button("Dodaj pole") {
                if !allCategories.contains(category) {
                    allCategories.insert(category)
                }

                let centerCoordinate = mapRegion.center
                let spanLoc = mapRegion.span
                var combinedHistory = ""

                if !oneyearago.isEmpty {
                    combinedHistory += "Rok temu: \(oneyearago)\n"
                }
                if !twoyearago.isEmpty {
                    combinedHistory += "Dwa lata temu: \(twoyearago)\n"
                }
                if !threeyearago.isEmpty {
                    combinedHistory += "Trzy lata temu: \(threeyearago)\n"
                }
                if !different.isEmpty {
                    combinedHistory += "Inne: \(different)\n"
                }
                                
                let newField = Field(location: centerCoordinate, span: spanLoc, category: category, history: combinedHistory, drawnPath: drawnPoints)
                
                onAddField(newField)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    private func convertToMapCoordinates(_ point: CGPoint, in size: CGSize) -> CGPoint {
            let mapWidth = size.width
            let mapHeight = size.height
            
            let xPos = point.x / mapWidth
            let yPos = point.y / mapHeight
            
            let longitudeDelta = mapRegion.span.longitudeDelta
            let latitudeDelta = mapRegion.span.latitudeDelta
            
            let newLongitude = mapRegion.center.longitude + (xPos - 0.5) * longitudeDelta
            let newLatitude = mapRegion.center.latitude - (yPos - 0.5) * latitudeDelta
            
            return CGPoint(x: newLongitude, y: newLatitude)
        }
}

struct Fields_Previews: PreviewProvider {
    static var previews: some View {
        Fields()
    }
}
