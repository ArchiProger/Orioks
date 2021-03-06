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
    @Published var currentDate = Date()
    @Published var selectedWeekday = getWeekday(day: Date())
    @Published var windowsData: [WindowsData] = []
    @Published var semester = Semester(semester_start: "")
    
    private var timetable = Timetable(Data: [], Times: [])
    
    func windowIndex(ind: Int) -> Int
    {
        for i in self.windowsData.indices
        {
            if self.windowsData[i].index == ind
            {
                return i
            }
        }
        
        return -1
    }
    
    private func updateWindowsSchedule()
    {
        self.windowsData.removeAll()
        
        for i in self.pairData.indices
        {
            if self.pairData[i]!.pairExists()
            {
                if self.windowsData.count != 0 && !self.pairData[i - 1]!.pairExists()
                {
                    self.windowsData[self.windowsData.count - 1].updateTimes(timeFrom: nil, timeTo: self.pairData[i]!.timeFrom)
                }
            }
            
            else if i != 0
            {
                if self.pairData[i - 1]!.pairExists()
                {
                    self.windowsData.append(WindowsData(timeFrom: self.pairData[i - 1]!.timeTo, timeTo: self.pairData[i]!.timeTo, index: i))
                }
            }
        }
        
        if self.windowsData.last != nil
        {
            self.windowsData.remove(at: self.windowsData.count - 1)
        }
    }
    
    private func timeStr2timeDate(time: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.date(from: time)!
    }
    
    private func getSelectedDaySchedule()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let semesterStart = dateFormatter.date(from: self.semester.semester_start)!
        let timedelta = Calendar.current.dateComponents([.day], from: semesterStart, to: self.currentDate).day!
        let week = (timedelta / 7) % 4
        
        self.pairData = .init(repeating: nil, count: self.timetable.Times.count)
        
        for t in self.timetable.Times
        {
            let index = Int(t.Time.components(separatedBy: " ")[0])! - 1
            
            self.pairData[index] = .init(timeFrom: timeStr2timeDate(time: t.TimeFrom), timeTo: timeStr2timeDate(time: t.TimeTo), name: nil, teacherName: nil, room: nil)
        }
        
        for dt in self.timetable.Data
        {
            if dt.DayNumber == week && dt.Day == self.selectedWeekday
            {
                let index = Int(dt.Time.Time.components(separatedBy: " ")[0])! - 1
                
                self.pairData[index]!.teacherName = dt.Class.TeacherFull
                self.pairData[index]!.room = dt.Room.Name
                self.pairData[index]!.name = dt.Class.Name
            }
        }
        
        self.updateWindowsSchedule()
    }
    
    func updateDate(currentDate: Date)
    {
        self.currentDate = currentDate
        self.selectedWeekday = getWeekday(day: self.currentDate)
        
        self.getSelectedDaySchedule()
    }
    
    func scheduleRequest(settings: SettingsData)
    {
        let param =
        [
            "group": settings.groupsList[settings.group]
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
                        self.timetable = try JSONDecoder().decode(Timetable.self, from: doc.data(using: .isoLatin1, allowLossyConversion: true)!)
                        
                        let head =
                        [
                            "Authorization": "Bearer " + settings.token!,
                            "Accept": "application/json",
                            "User-Agent": "api_tester/0.1 venv python"
                        ]
                        
                        Alamofire.request("https://orioks.miet.ru/api/v1/schedule", method: .get, headers: head)
                            .responseString {response in
                                
                                switch response.result
                                {
                                case .success(let value):
                                    
                                    do
                                    {
                                        self.semester = try JSONDecoder().decode(Semester.self, from: Data(value.utf8))                                                                                
                                        
                                        self.getSelectedDaySchedule()
                                    }
                                    catch
                                    {
                                        print(error)
                                    }
                                    
                                case .failure(let error):
                                    print(error)
                                    
                                }
                            }
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
    
    func pairCount() -> Int
    {
        var count = 0
        
        for pair in pairData
        {
            if pair!.pairExists()
            {
                count += 1
            }
        }
        
        return count
    }
}

class PairData
{
    var timeFrom: Date
    var timeTo: Date
    var name: String?
    var teacherName: String?
    var room: String?
    
    var type: String = ""
    
    init
    (
        timeFrom: Date,
        timeTo: Date,
        name: String?,
        teacherName: String?,
        room: String?
    )
    {
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        self.name = name
        self.teacherName = teacherName
        self.room = room
    }
    
    func formatData()
    {
        let separatedString = name!.components(separatedBy: "[")
        
        if separatedString.count == 1
        {
            let types = ["Лекция", "Практика", "Лаба", "Пара"]
            
            if types.firstIndex(of: separatedString[0]) != nil
            {
                self.type = separatedString[0]
            }
            
            else
            {
                self.type = "Пара"
            }
        }
        
        else
        {
            self.name = separatedString[0]
            
            switch separatedString[1].components(separatedBy: "]")[0]
            {
            case "Лек":
                self.type = "Лекция"
            case "Пр":
                self.type = "Практика"
            default:
                self.type = "Лаба"
            }
        }
    }
    
    func pairExists() -> Bool
    {
        return !(name == nil && teacherName == nil && room == nil)
    }
}

class WindowsData
{
    var timeFrom: Date
    var timeTo: Date
    var index: Int
    
    init(timeFrom: Date, timeTo: Date, index: Int)
    {
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        self.index = index
    }
    
    func updateTimes(timeFrom: Date?, timeTo: Date?)
    {
        if timeFrom != nil
        {
            self.timeFrom = timeFrom!
        }
        
        if timeTo != nil
        {
            self.timeTo = timeTo!
        }
    }
}

struct Window: View
{
    @Binding var windowData: WindowsData
    
    private func getTimeInterval() -> String
    {
        let calendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.hour, .minute]
        let interval = calendar.dateComponents(requestedComponent, from: self.windowData.timeFrom, to: self.windowData.timeTo)
        
        return "Окно \(interval.hour!) ч. \(interval.minute!) мин."
    }
    
    var body: some View
    {
        HStack
        {
            Image(systemName: "waveform.path.ecg")
                .foregroundColor(Color("ElementsColor"))
            
            Text(self.getTimeInterval())
                .font(.system(size: UIScreen.screenWidth * 0.04))
        }
    }
}

struct Pair: View
{
    let number: Int
    @Binding var pairData: PairData?
    
    private func getTime(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: date)
    }
    
    init(number: Int, pairData: Binding<PairData?>)
    {
        self.number = number
        self._pairData = pairData
        
        self.pairData!.formatData()
    }
    
    var body: some View
    {
        ZStack
        {
            VStack(alignment: .leading, spacing: 3)
            {
                HStack
                {
                    Text("\(self.number) " + self.pairData!.type)
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                        .fontWeight(.bold)
                        .background(
                            Capsule()
                                .fill(Color("ElementsColor"))
                                .frame(width: UIScreen.screenWidth * 0.3)
                        )
                        .frame(width: UIScreen.screenWidth * 0.25)
                    
                    Spacer()
                    
                    Text(self.getTime(date: self.pairData!.timeFrom) + "-" + self.getTime(date: self.pairData!.timeTo))
                        .font(.system(size: UIScreen.screenWidth * 0.03))
                        .fontWeight(.bold)
                }
                
                Text(self.pairData!.name!)
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .fontWeight(.heavy)
                
                Text(self.pairData!.teacherName!)
                    .font(.system(size: UIScreen.screenWidth * 0.03))
                    .fontWeight(.light)
                
                Spacer()
                
                Text(self.pairData!.room!)
                    .font(.system(size: UIScreen.screenWidth * 0.03))
                
            }.padding()
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.17)
        .background(Color("MarksCard.Background"))
        .cornerRadius(20)
    }
}

struct Dates: View
{
    @Binding var datesArray: [Date]
    
    @EnvironmentObject var networkSchedule: NetworkSchedule
    
    private let calendar = Calendar.current
    
    var body: some View
    {
        HStack(spacing: UIScreen.screenHeight * 0.025)
        {
            ForEach(datesArray.indices) { i in
                
                Text("\(calendar.component(.day, from: datesArray[i]))")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .fontWeight(.bold)
                    .opacity((i == 5 || i == 6) ? 0.5 : 1)
                    .frame(width: UIScreen.screenWidth * 0.06)
                    .padding(3)
                    .background(Circle().fill(i + 1 == self.networkSchedule.selectedWeekday ? Color("ElementsColor") : Color.clear))
                    .onTapGesture {
                        
                        self.networkSchedule.updateDate(currentDate: datesArray[i])
                        
                    }
            }
        }
    }
}

struct DaysLine: View
{
    @State private var datesArray: [[Date]] = []
    @State private var offsetWidth: CGFloat = 0
    
    @EnvironmentObject var networkSchedule: NetworkSchedule
    
    private let calendar = Calendar.current
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private func updateWeeks(width: CGFloat)
    {
        self.networkSchedule.selectedWeekday = getWeekday(day: self.networkSchedule.currentDate)
        let monday = self.calendar.date(byAdding: .day, value: -self.networkSchedule.selectedWeekday + 1, to: self.networkSchedule.currentDate)!
        
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
        let monday = self.calendar.date(byAdding: .day, value: -getWeekday(day: Date()) + 1, to: Date())!
        
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
    
    init()
    {
        getWeeksM()
    }
    
    var body: some View
    {
        ZStack
        {
            VStack()
            {
                HStack(spacing: UIScreen.screenHeight * 0.025)
                {
                    ForEach(weekdays.indices) { i in
                        Text(weekdays[i])
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                            .fontWeight(.bold)
                            .opacity((i == 5 || i == 6) ? 0.5 : 1)
                            .frame(width: UIScreen.screenWidth * 0.06)
                            .padding(3)
                    }
                }
                
                Spacer()
                
                GeometryReader { geometry in
                    
                    HStack
                    {
                        ForEach(self.datesArray.indices) {i in
                            Dates(datesArray: self.$datesArray[i])
                                .environmentObject(self.networkSchedule)
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
                                self.networkSchedule.updateDate(currentDate: calendar.date(byAdding: .weekdayOrdinal, value: value.translation.width < 0 ? 1 : -1, to: self.networkSchedule.currentDate)!)
                                self.updateWeeks(width: value.translation.width)
                                self.offsetWidth = 0
                            }
                    )
                }.frame(height: UIScreen.screenHeight * 0.01)
                
                Spacer()
                
                Text(self.networkSchedule.currentDate, format: Date.FormatStyle().day().month().year())
                    .font(.system(size: UIScreen.screenWidth * 0.035))
                    .italic()
            }
        }
        .padding(5)
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.1)
        .background(Color("MarksCard.Background"))
        .cornerRadius(20)
    }
}

struct Schedule: View
{
    @Binding var menuOpen: Bool        
    
    @StateObject var networkSchedule = NetworkSchedule()
    
    @EnvironmentObject var settings: SettingsData    
    
    var body: some View
    {
        NavigationView()
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)
                
                VStack()
                {
                    DaysLine().environmentObject(self.networkSchedule)
                        .padding()
                    
                    Spacer()
                    
                    if self.networkSchedule.pairCount() != 0
                    {
                        ScrollView(showsIndicators: false)
                        {
                            ForEach(self.networkSchedule.pairData.indices.filter()
                                    {
                                self.networkSchedule.pairData[$0]!.pairExists() ?
                                true :
                                self.networkSchedule.windowIndex(ind: $0) != -1
                                
                            }, id: \.self) { i in
                                
                                if self.networkSchedule.windowIndex(ind: i) == -1
                                {
                                    Pair(number: i + 1, pairData: self.$networkSchedule.pairData[i])
                                        .padding([.trailing, .leading], 10)
                                        .shadow(radius: 5)
                                }
                                
                                else
                                {
                                    Window(windowData: self.$networkSchedule.windowsData[self.networkSchedule.windowIndex(ind: i)])
                                }
                            }
                        }
                    }
                    
                    else
                    {
                        HStack
                        {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(Color("ElementsColor"))
                            
                            Text("Пар нет")
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                        }
                        
                        Spacer()
                    }
                }
            }        
            .navigationBarTitle("Расписание", displayMode: .automatic)
            .navigationBarItems(
                trailing:
                    Image(systemName: self.menuOpen ? "xmark.app.fill" : "menucard.fill")
                        .resizable()
                        .foregroundColor(Color("ElementsColor"))
                        .frame(width: UIScreen.screenWidth * 0.06, height: UIScreen.screenWidth * 0.06)
                        .onTapGesture
                        {
                            self.menuOpen.toggle()
                        }
            )
        }
        .onAppear()
        {
            self.networkSchedule.scheduleRequest(settings: self.settings)
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
