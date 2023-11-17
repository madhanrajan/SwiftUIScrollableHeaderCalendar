//
//  CalenderHeaderView.swift
//  Book Insights
//
//  Created by Madhan on 18/11/2023.
//

import SwiftUI

struct CalendarView: View {
    
    @State private var selectedMonth: Date = .currentMonth
    @State private var selectedDate: Date  = .now
    
    var currentMonth: String{
        format("MMMM")
    }
    
    var currentYear: String{
        format("YYYY")
    }
    
    var calendarTitleViewHeight: CGFloat {
        75
    }
    
    var calendarGridHeight: CGFloat {
        CGFloat(datesFromMonth.count / 7) * 40
    }
    
    var horizontalPadding: CGFloat = 15
    var topPadding: CGFloat = 15
    var bottomPadding: CGFloat = 5
    var weekLabelHeight: CGFloat = 30
    
    var calendarHeight: CGFloat{
        calendarTitleViewHeight + calendarGridHeight + weekLabelHeight + topPadding + bottomPadding
    }
    
    var datesFromMonth: [Day] {
        Date.getDates(selectedMonth)
    }
    
    @State var resize = false
    
    var body: some View {
        ScrollView{
            
            calendarView()
            
            VStack{
                ForEach(0..<50) { i in
                    Text("hello")
                        .padding()
                        .background(.blue)
                        .padding()
                }
            }
            
            
        }
        
        .coordinateSpace(name: "scroll")
        
    }
    
    @ViewBuilder
    func calendarView() -> some View{
        GeometryReader {
            let size = $0.size
            let minY = $0.frame(in: .named("scroll")).minY
            let maxHeight = size.height - (calendarTitleViewHeight + weekLabelHeight + topPadding + bottomPadding)
            let progress = max(min((-minY / maxHeight), 1), 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(currentMonth)
                    .font(.system(size: 35 - (10 * progress)))
                    .offset(y: -50 * progress)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    .overlay(alignment: .topLeading) {
                        GeometryReader {
                            let size = $0.size
                            
                            Text(currentYear)
                                .font(.system(size: 25 - (10 * progress)))
                                .offset(x: (size.width + 5) * progress, y: progress * 3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment:.leading)
                    .overlay(alignment: .topTrailing ,content: {
                        HStack(spacing: 15){
                            Button{
                                updateMonth(increment: false)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .contentShape(Rectangle())
                            }
                            Button{
                                updateMonth(increment: true)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .contentShape(Rectangle())
                            }
                        }
                        .font(.title3)
                        .foregroundColor(.primary)
                        .offset(x: 150 * progress)
                    })
                
                    .frame(height: calendarTitleViewHeight)
                
                VStack {
                    HStack{
                        ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                            Text(symbol.prefix(3))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: weekLabelHeight, alignment: .bottom)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                     
                        ForEach(datesFromMonth) { day in
                            Text(day.shortSymbol)
                                .foregroundColor(day.unHighlight ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                                .overlay(alignment: .bottom, content: {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 30, height: 30)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? 1 : 0)
                                        .overlay {
                                            if Calendar.current.isDate(day.date, inSameDayAs: selectedDate){
                                                Text(day.shortSymbol)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                })
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedDate = day.date
                                    }
                                }
                        }
                        
                    }
                    .frame(height: calendarGridHeight)
                    .clipped()
                }
                .offset(y: progress * -50)
            }
            
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .frame(maxHeight: .infinity)
            .frame(height: size.height - maxHeight * progress, alignment: .top)
            .background(.blue.gradient)
            .cornerRadius(15)
            .padding(.horizontal)
            .clipped()
            .offset(y: min(maxHeight,-minY) )
            .contentShape(Rectangle())
        }
        .frame(height: calendarHeight)
        
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: selectedMonth)
    }
    
    func updateMonth(increment: Bool = false){
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedMonth) else { return }
        selectedMonth = month
    }
    
}

struct CalenderHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .preferredColorScheme(.dark)
    }
}

extension Date{
    static var currentMonth: Date{
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.month,.year], from: .now)) else {
            return .now
        }
        return currentMonth
    }
    
//    Lists dates for a given month
    static func getDates(_ month: Date) -> [Day]{
        
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {return []}

        let firstWeekday = calendar.component(.weekday, from: range.first!)
        
        for index in Array(0..<firstWeekday - 1).reversed(){
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else { return days }
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date, unHighlight: true))
        }
        
        
        
        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date))
        }
        
        let lastWeekday = 7 - calendar.component(.weekday, from: range.last!)
        
        if lastWeekday > 0{
            for index in 0..<lastWeekday{
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, unHighlight: true))
            }
        }
        
        return days
    }
    
}


struct Day: Identifiable {
    var id = UUID()
    var shortSymbol: String
    var date: Date
//    Highlights dates from previous/next month
    var unHighlight: Bool = false
    
}
