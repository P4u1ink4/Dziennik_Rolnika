
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TaskViewModel()
    @State private var showAddTaskSheet = false
    @State private var isDeleting = false
    @State private var deleteWorkItem: DispatchWorkItem?
    @State private var taskToDeleteIndex: Int?
    @State private var offset: CGSize = .zero
    @State private var weatherDescription: String = "Loading..."
    
    private func startDeleting(at index: Int) {
            isDeleting = true
            taskToDeleteIndex = index
            deleteWorkItem = DispatchWorkItem {
                endDeleting()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: deleteWorkItem!)
        }

    private func endDeleting() {
            isDeleting = false
            taskToDeleteIndex = nil
            deleteWorkItem?.cancel()
            deleteWorkItem = nil
    }
    
    private func getWeatherForPoznan() {
            guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=d0135269911a4872854214646233107&q=Poznan") else {
                print("Nieprawidłowy adres URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherResponse = try decoder.decode(WeatherData.self, from: data)
                        DispatchQueue.main.async {
                            weatherDescription = weatherResponse.current.condition.text
                        }
                    } catch {
                        print("Błąd dekodowania danych: \(error)")
                    }
                }
            }.resume()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text(currentDateFormatted())
                    .font(.title)
                HStack{
                    Image("\(weatherDescription)")
                    Text("\(weatherDescription)")
                        .foregroundColor(Color("MyColor2"))
                                
                    Button("Odśwież") {
                        getWeatherForPoznan()
                    }
                    .padding(5.0)
                    .foregroundColor(Color("MyColor2"))
                }
                Spacer()
                    .frame(height: 20.0)
                VStack {
                    HStack{
                        Text("DO ZROBIENIA:")
                            .font(.subheadline)
                            .frame(width: 200.0)
                        Button("+") { showAddTaskSheet.toggle() }
                    }
                    ScrollView{
                        VStack(spacing: 10) {
                            ForEach(viewModel.tasks.indices, id: \.self) { index in
                                let task = viewModel.tasks[index]
                                Text(task)
                                    .frame(width: 200.0)
                                    .foregroundColor(Color("MyColor2"))
                                    .font(.footnote)
                                    .offset(x: isDeleting && taskToDeleteIndex == index ? offset.width : 0, y: 0)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                if !isDeleting {
                                                    startDeleting(at: index)
                                                }
                                                offset = value.translation
                                                if value.translation.width > 0 { offset = .zero }
                                            }
                                            .onEnded { value in
                                                endDeleting()
                                                offset = .zero
                                                if value.translation.width < -100 {
                                                    let indexSet = IndexSet([index])
                                                    viewModel.removeTask(at: indexSet)
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    .frame(height: 100.0)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hue: 1.0, saturation: 0.013, brightness: 0.304), lineWidth: 2)
                )
                .sheet(isPresented: $showAddTaskSheet, content: {
                            AddTaskView(onAddTask: { title in
                                viewModel.addTask(title: title)
                                showAddTaskSheet = false
                            })
                        })
                
                Spacer()
                    .frame(height: 20.0)
                VStack(alignment: .center, spacing: 50.0){
                    NavigationLink(destination: YearCalender()) {
                        Text("Kalendarz roczny")
                            .foregroundColor(Color("MyColor2"))
                    }
                    NavigationLink(destination: Cows()) {
                        Text("Spis krów")
                            .foregroundColor(Color("MyColor2"))
                    }
                    NavigationLink(destination: Fields()) {
                        Text("Spis pól")
                            .foregroundColor(Color("MyColor2"))
                    }
                    }
                    .padding()

            }
        }
    }
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [String] = []

    private let tasksKey = "savedTasksKey"

    init() {
        loadTasks()
    }

    func addTask(title: String) {
        if(!title.isEmpty){
            tasks.append(title)
        }
        saveTasks()
    }

    func removeTask(at index: IndexSet) {
        tasks.remove(atOffsets: index)
        saveTasks()
    }

    private func saveTasks() {
        UserDefaults.standard.set(tasks, forKey: tasksKey)
    }

    private func loadTasks() {
        if let savedTasks = UserDefaults.standard.array(forKey: tasksKey) as? [String] {
            tasks = savedTasks
        }
    }
}


struct AddTaskView: View {
    @State private var taskTitle = ""
    var onAddTask: (String) -> Void

    var body: some View {
        VStack {
            TextField("Nowe zadanie", text: $taskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Dodaj zadanie") {
                onAddTask(taskTitle)
            }
            .padding()
            .accentColor(.blue)

            Spacer()
        }
    }
}

func currentDateFormatted() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    return dateFormatter.string(from: Date())
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
