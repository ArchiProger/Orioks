//
//  Schedule.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 05.02.2022.
//

import SwiftUI
import Alamofire
import Kanna

func getWeekday(day: Date) -> Int
{
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: day)
    
    switch weekday
    {
    case 1:
        return 7
    case 2:
        return 1
    case 3:
        return 2
    case 4:
        return 3
    case 5:
        return 4
    case 6:
        return 5
    default:
        return 6
    }
}

class NetworkSchedule: ObservableObject
{
    @Published var pairData: [PairData?] = []
    @Published var today = Date()
    @Published var selectedWeekday = getWeekday(day: Date())
    
    private func timeStr2timeDate(time: String) -> Date
    {
        let spl = time.components(separatedBy: "T")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.date(from: spl[1])!
    }
    
    private func getSelectedDaySchedule(timetable: Timetable)
    {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: self.today) % 4
                
        self.pairData = .init(repeating: nil, count: timetable.Times.count)
        
        for t in timetable.Times
        {
            let index = Int(t.Time.components(separatedBy: " ")[0])! - 1
            
            self.pairData[index] = .init(timeFrom: timeStr2timeDate(time: t.TimeFrom), timeTo: timeStr2timeDate(time: t.TimeTo), code: nil, name: nil, teacherName: nil, room: nil)
        }
        
        for dt in timetable.Data
        {
            if dt.DayNumber == week && dt.Day == self.selectedWeekday
            {
                self.pairData[dt.Time.Code - 1]!.code = dt.Time.Code
                self.pairData[dt.Time.Code - 1]!.teacherName = dt.Class.TeacherFull
                self.pairData[dt.Time.Code - 1]!.room = dt.Room.Name
                self.pairData[dt.Time.Code - 1]!.name = dt.Class.Name
            }
        }
    }
    
    func scheduleRequest(group: String)
    {
        let param =
        [
            "group": group
        ]
        
        Alamofire.request("https://miet.ru/schedule/data", method: .post, parameters: param, headers: nil).responseString { response in
            
            switch response.result
            {
            case .success(_):
                if let html = response.result.value
                {
                    do
                    {
                        let doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8).text!
                        let data = try JSONDecoder().decode(Timetable.self, from: Data(doc.utf8))
                        
                        self.getSelectedDaySchedule(timetable: data)
                    }
                    catch
                    {
                        print("Failet to open HTML document")
                        print(error)
                    }
                }

            case .failure(let error):
                print(error)
            }
        }
    }
}

struct PairData
{
    var timeFrom: Date
    var timeTo: Date
    var code: Int?
    var name: String?
    var teacherName: String?
    var room: String?
    
    func pairExists() -> Bool
    {
        return !(code == nil && name == nil && teacherName == nil && room == nil)
    }
}

struct Pair: View
{
    @Binding var pairData: PairData?
    
    var body: some View
    {
        ZStack
        {
            VStack(alignment: .leading, spacing: 3)
            {
                HStack
                {
                    Text("1 практика")
                        .fontWeight(.bold)
                        .background(
                            Capsule()
                                .fill(Color("ElementsColor"))
                                .frame(width: UIScreen.screenWidth * 0.25)
                        )
                        .frame(width: UIScreen.screenWidth * 0.25)
                    
                    Spacer()
                    
                    Text("\(self.pairData!.timeFrom)-\(self.pairData!.timeTo)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                Text(self.pairData!.name!)
                    .font(.body)
                    .fontWeight(.heavy)
                
                Text(self.pairData!.teacherName!)
                    .font(.footnote)
                    .fontWeight(.light)
                
                Spacer()
                
                Text(self.pairData!.room!)
                    .font(.subheadline)
                                
            }.padding()
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.12)
        .background(Color("MarksCard.Background"))
        .cornerRadius(20)
    }
}

struct Dates: View
{
    @Binding var currentDate: Date
    @Binding var selectedWeekday: Int
    @Binding var datesArray: [Date]
    
    private let calendar = Calendar.current
    
    var body: some View
    {
        HStack(spacing: UIScreen.screenHeight * 0.025)
        {
            ForEach(datesArray.indices) { i in
                
                Text("\(calendar.component(.day, from: datesArray[i]))")
                    .fontWeight(.bold)
                    .opacity((i == 5 || i == 6) ? 0.5 : 1)
                    .frame(width: UIScreen.screenWidth * 0.07)
                    .background(Circle().fill(i + 1 == self.selectedWeekday ? Color("ElementsColor") : Color.clear))
                    .onTapGesture {
                        self.currentDate = datesArray[i]
                        self.selectedWeekday = i + 1
                    }
            }
        }
    }
}

struct DaysLine: View
{
    @Binding var currentDate: Date
    @Binding var selectedWeekday: Int
    
    @State private var datesArray: [[Date]] = []
    @State private var offsetWidth: CGFloat = 0
    
    private let calendar = Calendar.current
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private func updateWeeks(width: CGFloat)
    {
        self.selectedWeekday = getWeekday(day: self.currentDate)
        let monday = self.calendar.date(byAdding: .day, value: -selectedWeekday + 1, to: self.currentDate)!
        
        self.datesArray.remove(at: width < 0 ? 2 : 0)
        var newDates: [Date] = []
        
        for i in weekdays.indices
        {
            let day = self.calendar.date(byAdding: .day, value: i, to: monday)!
            let dayAfter = self.calendar.date(byAdding: .weekdayOrdinal, value: 1, to: day)!
            
            newDates.append(dayAfter)
        }
        
        self.datesArray.insert(newDates, at: width < 0 ? 2 : 0)
        
        for i in weekdays.indices
        {
            let day = self.calendar.date(byAdding: .day, value: i, to: monday)!
            let dayBefore = self.calendar.date(byAdding: .weekdayOrdinal, value: -1, to: day)!
            let dayAfter = self.calendar.date(byAdding: .weekdayOrdinal, value: 1, to: day)!
            
            self.datesArray[0][i] = dayBefore
            self.datesArray[1][i] = day
            self.datesArray[2][i] = dayAfter
        }
    }
    
    private mutating func getWeeksM()
    {
        let monday = self.calendar.date(byAdding: .day, value: -selectedWeekday + 1, to: self.currentDate)!
        
        var weekToday: [Date] = []
        var weekBefore: [Date] = []
        var weekAfter: [Date] = []
        var weeks: [[Date]] = []
        
        for i in weekdays.indices
        {
            let day = self.calendar.date(byAdding: .day, value: i, to: monday)!
            let dayBefore = self.calendar.date(byAdding: .day, value: -7, to: day)!
            let dayAfter = self.calendar.date(byAdding: .day, value: 7, to: day)!
            
            weekToday.append(day)
            weekBefore.append(dayBefore)
            weekAfter.append(dayAfter)
        }
        
        weeks.append(weekBefore)
        weeks.append(weekToday)
        weeks.append(weekAfter)
        
        self._datesArray = State(initialValue: weeks)
    }
    
    init(selectedWeekday: Binding<Int>, today: Binding<Date>)
    {
        self._selectedWeekday = selectedWeekday
        self._currentDate = today
        
        getWeeksM()
    }
    
    var body: some View
    {
        ZStack
        {
            VStack(spacing: 5)
            {
                HStack(spacing: UIScreen.screenHeight * 0.025)
                {
                    ForEach(weekdays.indices) { i in
                        Text(weekdays[i])
                            .fontWeight(.bold)
                            .opacity((i == 5 || i == 6) ? 0.5 : 1)
                            .frame(width: UIScreen.screenWidth * 0.07)
                    }
                }
                GeometryReader { geometry in
                    
                    HStack
                    {
                        ForEach(self.datesArray.indices) {i in
                            Dates(currentDate: self.$currentDate, selectedWeekday: self.$selectedWeekday, datesArray: self.$datesArray[i])
                        }
                    }
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    .offset(x: self.offsetWidth)
                    .gesture(
                        DragGesture()
                            .onChanged() {value in
                                self.offsetWidth = value.translation.width
                            }
                            .onEnded() {value in
                                self.currentDate = calendar.date(byAdding: .weekdayOrdinal, value: value.translation.width < 0 ? 1 : -1, to: self.currentDate)!
                                updateWeeks(width: value.translation.width)
                                self.offsetWidth = 0
                            }
                    )
                }.frame(height: 30)
                
                Text(self.currentDate, format: Date.FormatStyle().day().month().year())
                    .font(.subheadline)
            }
        }
        .frame(width: UIScreen.screenWidth * 0.85, height: UIScreen.screenHeight * 0.1)
        .background(Color("MarksCard.Background"))
        .cornerRadius(20)
            
    }
}

struct Schedule: View
{
    @Binding var group: String
    @Binding var menuOpen: Bool
    
    @ObservedObject var networkSchedule = NetworkSchedule()
    
    init(group: Binding<String>, menuOpen: Binding<Bool>)
    {
        self._group = group
        self._menuOpen = menuOpen
        
        self.networkSchedule.scheduleRequest(group: self.group)
    }
    
    var body: some View
    {
        NavigationView()
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)
                
                VStack()
                {
                    DaysLine(selectedWeekday: self.$networkSchedule.selectedWeekday, today: self.$networkSchedule.today)
                        .padding()
                    Spacer()
                    
                    ScrollView
                    {                        
                        ForEach(self.networkSchedule.pairData.indices.filter() {self.networkSchedule.pairData[$0]!.pairExists()}, id: \.self) {i in
                           
                            Pair(pairData: self.$networkSchedule.pairData[i])
                            
                        }
                    }
                }
            }
            .navigationBarTitle("Расписание", displayMode: .automatic)
            .navigationBarItems(trailing:
                Image(self.menuOpen ? "Exit" : "Menu")
                    .resizable()
                    .frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenWidth * 0.05)
                    .onTapGesture {
                        self.menuOpen.toggle()
                    }
            )
        }
    }
}

struct Schedule_Previews: PreviewProvider
{
    static var previews: some View
    {
        EmptyView()
            .preferredColorScheme(.dark)
    }
}
