//
//  ViewController.swift
//  TableViewDates
//
//  Created by Pardy Panda's New Mac Mini on 17/06/22.
//

import UIKit

class ViewController: UIViewController {

    
    var DateArray = Date()
    let calendar = Calendar(identifier: .gregorian)
    var beforeArray = [Date]()
    var nextArray = [Date]()
    var wholeArray = [Date]()
    var selectedDate = Date()
    
    var visibleRect = CGRect()
    var visiblePoint = CGPoint()
    var visibleIndexPath = IndexPath()
    
    let formatter = DateFormatter()
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextMonthLabel: UILabel!
    @IBOutlet weak var datesCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datesCollectionView.delegate = self
        datesCollectionView.dataSource = self
        
        datesCollectionView.register(UINib(nibName: "TimelineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineCollectionViewCell")
        getDates()
        checkForCurrentDate()
        
        visibleRect = CGRect(origin: datesCollectionView.contentOffset, size: datesCollectionView.bounds.size)
        visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        visibleIndexPath = datesCollectionView.indexPathForItem(at: visiblePoint) ?? IndexPath()
    }
    
    
    func getDates() {
        let currentDate = Date()
        beforeArray = []
        nextArray = [Date()]
        wholeArray = []
        
        for i in 1 ... 100 {
            let previous100Dates =  calendar.date(byAdding: .day, value: -i, to: currentDate) ?? Date()
            beforeArray.append(previous100Dates.startOfDay)
        }
        for i in 1 ... 1000 {
            let previous100Dates =  calendar.date(byAdding: .day, value: i, to: currentDate) ?? Date()
            nextArray.append(previous100Dates.startOfDay)
        }
        wholeArray = beforeArray.sorted() + nextArray
        self.datesCollectionView.reloadData()
        
    }
    
    func checkForCurrentDate() {
        for i in 0 ..< wholeArray.count {
            let formattedArrDate = formatter.string(from: wholeArray[i])

            formatter.dateFormat = "dd MM YYYY"
            let formattedToday = formatter.string(from: Date())

            
            if formattedArrDate == formattedToday {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: i - 1, section: 0)
                    self.datesCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
                }
            }
        }
    }


}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wholeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = datesCollectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCollectionViewCell", for: indexPath) as! TimelineCollectionViewCell

        formatter.dateFormat = "dd"
        let day = formatter.string(from: wholeArray[indexPath.row])
        cell.dateLabel.text = day
        
        formatter.dateFormat = "E"
        let date = formatter.string(from: wholeArray[indexPath.row])
        cell.dayLabel.text = date
        
        formatter.dateFormat = "dd MM YYYY"
        let formattedArrDate = formatter.string(from: wholeArray[indexPath.row])
        formatter.dateFormat = "dd MM YYYY"
        let formattedToday = formatter.string(from: selectedDate)
        if formattedToday == formattedArrDate {
            
            
            
            cell.bgImg.image = UIImage(named: "bg")
            cell.dateLabel.textColor = .white
            cell.dayLabel.textColor = .white
        } else {
            cell.bgImg.image = UIImage(named: "graybg")
            cell.dateLabel.textColor = .black
            cell.dayLabel.textColor = .black
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(wholeArray[indexPath.row].localDate())
        self.selectedDate = wholeArray[indexPath.row]
        self.datesCollectionView.reloadData()
    }

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in datesCollectionView.visibleCells {
            let indexPath = datesCollectionView.indexPath(for: cell)
            formatter.dateFormat = "MMM"
            let nextMonth =  calendar.date(byAdding: .month, value: 1, to: wholeArray[indexPath?.row ?? 0].localDate()) ?? Date()
            let monthName = formatter.string(from: wholeArray[indexPath?.row ?? 0].localDate())
            let nextMonthStr = formatter.string(from: nextMonth)
            self.monthLabel.text = monthName
            self.nextMonthLabel.text = nextMonthStr
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        for cell in datesCollectionView.visibleCells {
            let indexPath = datesCollectionView.indexPath(for: cell)
            formatter.dateFormat = "MMM"
            let monthName = formatter.string(from: wholeArray[indexPath?.row ?? 0].localDate())
            self.monthLabel.text = monthName
        }
    }
    
    
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}
        
        return localDate
    }
}
