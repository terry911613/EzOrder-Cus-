//
//  CalendarViewController.swift
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/5/19.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var showEventTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    //    @IBOutlet weak var eventTableView: UITableView!
    
    var now = Date()
    var dateText = ""
    var selectDateText = ""
    var eventDic = [String : [String]]()
    let dateFormatter: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "行事曆"
        // 讓app一啟動就是今天的日曆
        calendarView.scrollToDate(now, animateScroll: false)
        // 讓今天被選取
        calendarView.selectDates([now])
        
        //  設定日曆屬性（水平/垂直滑）、滑動方式
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        
        self.title = "行事曆"
        dateLabel.text = "2019-01"
        
        //  寫死今天有三項訂位
        dateText = dateFormatter.string(from: now)
        selectDateText = dateText
        print(dateText)
        print(selectDateText)
        eventDic = ["2019-05-15" : ["12:00 全家", "17:00 711"],
                    "2019-04-15" : ["12:00 馬辣", "17:00 新馬辣"],
                    "2019-03-15" : ["12:00 屋馬", "17:00 大呼過癮"],
                    "2019-02-15" : ["12:00 三媽", "22:00 老四川"],
                    "2019-01-15" : ["12:00 麥當勞", "22:00 肯德基"]]
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        //  設定dateFormatter格式
        /*
         這邊比viewdidload先執行，所以可以在這邊設定dateFormatter格式
         */
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        //  設定日曆起始日期和最終日期
        let startDate = dateFormatter.date(from: "2019-01-01")!
        let endDate = dateFormatter.date(from: "2030-02-01")!
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
        formatter.dateFormat = "yyyy-MM"
        if let slideYearMonth = visibleDates.monthDates.first?.date{
            let yearMonth = formatter.string(from: slideYearMonth)
            dateLabel.text = "\(yearMonth)"
        }
    }
    //  選取日期的話
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        //  判斷是不是點第二次，如果是點兩次的話跳出細項
//        let cell = cell as! DateCell
        
        configureCell(view: cell, cellState: cellState)
        selectDateText = dateFormatter.string(from: date)
        //        eventTableView.reloadData()
        print(selectDateText)
        //  讓標籤改成選取到的日期
        dateLabel.text = selectDateText
        showEventTableView.reloadData()
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
        if let eventArray = eventDic[selectDateText]{
            return eventArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.restaurantLabel.text = ""
        cell.timeLabel.text = ""
        cell.restaurantLabel.text = ""
        tableView.separatorStyle = .none
        if let eventArray = eventDic[selectDateText]{
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = .lightGray
            if eventArray.isEmpty{
                cell.restaurantLabel.text = ""
            }
            else{
                cell.timeLabel.text = selectDateText
                cell.restaurantLabel.text = eventArray[indexPath.row]
            }
        }
        return cell
    }
}
