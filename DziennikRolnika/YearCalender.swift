

import SwiftUI
import Foundation

struct YearCalender: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var isLegendPresented = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button(action: {
                    selectedYear -= 1
                }) {
                    Image(systemName: "chevron.left.circle")
                }
                Text(String(format: "%04d", selectedYear))
                    .font(.headline)
                Button(action: {
                    selectedYear += 1
                }) {
                    Image(systemName: "chevron.right.circle")
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(1...12, id: \.self) { month in
                        MonthView(year: selectedYear, month: month)
                    }
                }
                .padding()
            }
            
            Button(action: {
                isLegendPresented.toggle()
            }) {
                Text("Show Legend")
            }
            .padding(.bottom, 20)
            .sheet(isPresented: $isLegendPresented) {
                LegendView(isLegendPresented: $isLegendPresented)
            }
        }
        .padding(.top, 0.0)
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
}

struct MonthView: View {
    let year: Int
    let month: Int
    
    var body: some View {
        VStack {
            Text("\(getMonthName(month))")
                .font(.headline)
                .padding(.vertical, 10)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 10) {
                Text("pon")
                Text("wt")
                Text("śr")
                Text("czw")
                Text("pt")
                Text("sob")
                    .foregroundColor(.red)
                Text("nd")
                    .foregroundColor(.red)
                ForEach(getDaysOfMonth(year: year, month: month), id: \.self) { day in
                    let backgroundColor = getBackgroundColor(month: month, day: Int(day) ?? 0)
                    Text("\(day)")
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("MyColor"))
                        .background(backgroundColor)
                        .cornerRadius(15)
                }
            }
        }
        .padding()
        .border(Color.gray, width: 1)
    }
    
    func getDaysOfMonth(year: Int, month: Int) -> [String] {
        var days: [String] = []
        
        let firstDay = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))!
        let weekday = Calendar.current.component(.weekday, from: firstDay)
        if(weekday == 1){
            let emptyDays = Array(repeating: "", count: 6)
            days.append(contentsOf: emptyDays)
        }
        else{
            let emptyDays = Array(repeating: "", count: weekday - 2)
            days.append(contentsOf: emptyDays)
        }
        
        let range = Calendar.current.range(of: .day, in: .month, for: firstDay)!
        days.append(contentsOf: range.map { String($0) })
        
        return days
    }
}

func getBackgroundColor(month: Int, day: Int) -> Color {
    if let specialDay = specialDays.first(where: { $0.month == month && $0.day == day }) {
        return specialDay.color
    } else {
        return Color.clear
    }
}



struct LegendView: View {
    @Binding var isLegendPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LEGENDA")
                .font(.headline)
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.115, saturation: 0.745, brightness: 0.653))
                Text("Nawożenie pól, łąk obornikiem, kompostem")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.144, saturation: 0.962, brightness: 0.893))
                Text("Siew zbóż")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.48, saturation: 0.762, brightness: 0.893))
                Text("Orka, przekopywanie, bronowanie, wałowanie, niszczenie chwastów, nawożenie pól, łąk")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.271, saturation: 0.963, brightness: 0.949))
                Text("Siew lnu, kukurydzy, prosa, zbóż, ziemniaków")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.164, saturation: 1.0, brightness: 1.0))
                Text("Pierwsze sianokosy")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.294, saturation: 0.437, brightness: 0.981))
                Text("Redlenie, podorywki, niszczenie chwastów")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.752, saturation: 0.437, brightness: 0.981))
                Text("Ścinanie traw i żniwa zbóż")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.859, saturation: 0.437, brightness: 0.981))
                Text("Żniwa rzepaku i wczesnych ziemniaków")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.007, saturation: 0.27, brightness: 0.702))
                Text("Zbiór ziemniaków, nawożenie pól kompostem, orki, podorywki, bronowanie, spulchnianie okopywanie")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.314, saturation: 0.167, brightness: 0.702))
                Text("Zbiór kukurydzy")
            }
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(hue: 0.146, saturation: 0.491, brightness: 0.787))
                Text("Ścinanie trawy")
            }
            Spacer()
            Button(action: {
                isLegendPresented.toggle()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

func getMonthName(_ month: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "pl_PL")
    return dateFormatter.standaloneMonthSymbols[month-1]
}

func getDayOfWeekSymbol(_ dayOfWeek: Int) -> String {
    let dateFormatter = DateFormatter()
    return dateFormatter.shortWeekdaySymbols[dayOfWeek - 1]
}

func getNumberOfDaysInMonth(year: Int, month: Int) -> Int {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month)
    if let date = calendar.date(from: components), let range = calendar.range(of: .day, in: .month, for: date) {
        return range.count
    }
    return 0
}


struct YearCalender_Previews: PreviewProvider {
    static var previews: some View {
        YearCalender()
    }
}
