//
//  CountdownCell.swift
//  MultiDown
//
//  Created by John Salami on 17/8/20.
//  Copyright © 2020 -. All rights reserved.
//

import UIKit

public class CountdownCell: UITableViewCell {
    
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var title: UILabel!
    var timer: Timer?
    
    
    public func configure(item: Countdown) {
        title.text = item.title ?? "-"
        remaining.text = timeRemainingFormatted(duration(item))
        
        if duration(item) < 1 {
            return
        }
        
        
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.duration(item) < 1 {
                    self.timer?.invalidate()
                    self.timer = nil
                }
                self.remaining.text = self.timeRemainingFormatted(self.duration(item))
            }
        }
    }
    
    override public func prepareForReuse() {
        remaining.text = nil
        title.text = nil;
        timer?.invalidate()
        timer = nil
    }
    
    func duration(_ item: Countdown) -> TimeInterval {
        return TimeInterval(item.completion?.timeIntervalSinceNow ?? -1)
    }
    
    func timeRemainingFormatted(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter.string(from: duration) ?? ""
    }
}
