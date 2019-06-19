//
//  CalendarViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/19.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var showEventTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    //    @IBOutlet weak var eventTableView: UITableView!
    
    var now = Date()
    var selectDateText = ""
    var eventDic = [String : String]()
    let dateFormatter: DateFormatter = DateFormatter()
    var selectDateBooking = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 讓app一啟動就是今天的日曆
        calendarView.scrollToDate(now, animateScroll: false)
        // 讓今天被選取
        calendarView.selectDates([now])
        
        //  設定日曆屬性（水平/垂直滑）、滑動方式
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        
        
        selectDateText = dateFormatter.string(from: now)
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("booking").order(by: "date", descending: false).getDocuments { (booking, error) in
                if let booking = booking{
                    if booking.documents.isEmpty == false{
                        for booking in booking.documents{
                            if let bookingDateString = booking.data()["documentID"] as? String{
                                self.eventDic[bookingDateString] = "yes"
                                self.calendarView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        //  設定dateFormatter格式
        /*
         這邊比viewdidload先執行，所以可以在這邊設定dateFormatter格式
         */
        dateFormatter.dateFormat = "yyyy年M月d日"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        //  設定日曆起始日期和最終日期
        let startDate = dateFormatter.date(from: "2019年1月1日")!
        let endDate = dateFormatter.date(from: "2030年1月1日")!
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid)
        
    }
    
    /*
     cellForItemAt 和 willDisplay 裡面要放的東西幾乎一樣
     除了 cell 在 cellForItemAt 要做重複利用（dequeueReusableJTAppleCell）
     */
    //  每一格cell要呈現的日期
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    //  滑動日曆的話
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        //  讓 navigation 的 title 顯示現在的年跟月
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        if let slideYearMonth = visibleDates.monthDates.first?.date{
            let yearMonth = formatter.string(from: slideYearMonth)
            dateLabel.text = "\(yearMonth)"
        }
    }
    //  選取日期的話
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        //  判斷是不是點第二次，如果是點兩次的話跳出細項
        
        configureCell(view: cell, cellState: cellState)
        selectDateText = dateFormatter.string(from: date)
        dateLabel.text = selectDateText
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("user").document(userID).collection("booking").document(dateFormatter.string(from: date)).collection("bookDetail").order(by: "period", descending: false).getDocuments { (booking, error) in
                if let booking = booking{
                    if booking.documents.isEmpty{
                        self.selectDateBooking.removeAll()
                        self.showEventTableView.reloadData()
                    }
                    else{
                        self.selectDateBooking = booking.documents
                        self.showEventTableView.reloadData()
                    }
                }
            }
        }
    }
    //  取消選取的話
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell else{return}
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    //  讓不是這個月的日期變灰色
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = .black
            cell.isHidden = false
        } else {
            cell.dateLabel.textColor = .lightGray
        }
    }
    //  按日期讓日期上有粉色的圓圈
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    //  日期裡有事件的話，在日期下方標示
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let everyCellDayDate = dateFormatter.string(from: cellState.date)
        if eventDic[everyCellDayDate] == nil{
            cell.dotView.isHidden = true
        } else {
            cell.dotView.isHidden = false
        }
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectDateBooking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let booking = selectDateBooking[indexPath.row]
        if let dateString = booking.data()["dateString"] as? String,
            let period = booking.data()["period"] as? String,
            let resName = booking.data()["resName"] as? String,
            let people = booking.data()["people"] as? String{
               
            cell.restaurantLabel.text = resName
            cell.dateLabel.text = dateString
            cell.timeLabel.text = period
            cell.peopleLabel.text = "\(people)人"
        }
        return cell
    }
}
