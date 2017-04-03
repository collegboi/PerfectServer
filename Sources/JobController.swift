//
//  JobController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 30/03/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import Foundation
import SwiftCron
import SwiftMoment

private var _JobControllerSharedInstance: JobController?

public class JobController {
    
    var cron : Cron?
    var allJobs = [CronJob]()
    
    public class var sharedJobHandler: JobController? {
        return _JobControllerSharedInstance
    }
    
    @discardableResult
    public class func setup() -> JobController? {
        
        let jobController = JobController()
        
        return jobController
    }
    
    public init() {
        
        if (_JobControllerSharedInstance == nil) {
            _JobControllerSharedInstance = self
        }
        
        cron = Cron()
        //init cronjobs
        // var shouldKeepRunning = true        // change this `false` to stop the application from running
        //let theRL = RunLoop.current         // Need a reference to the current run loop
        
        self.getListOfJobs()
        
        //Start Cron So the Jobs Run
        cron?.start()
        
        //while shouldKeepRunning && theRL.run(mode: .defaultRunLoopMode, before: .distantFuture) {  }
    }
    
    private var timeFormatter : DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }

    private func doJobs() {
        BackupService.doBackupNow()
    }
    
    func deleteJob(_ index: Int ) {
        
        self.cron?.remove(self.allJobs[index])
    }
    
    private func  getListOfJobs() {
    
        let storage = Storage()
        storage.setAppKey("JKHSDGHFKJGH454645GRRLKJF")
        storage.setCollectionName("TBBackupSetting")
        
        let jobStr = storage.getCollectionStr()
        
        let jobObjects = JSONController.parseJSONToArrDic(jobStr)
        
        var index: Int = 0
        
        for jobObj in jobObjects {
            
            let jobTime: String = jobObj["time"] as? String ?? ""
            let repeatJob: Int = jobObj["repeatJob"] as? Int ?? 0
            //let backupJob: Int = jobObj["type"] as? Int ?? 0
            
            if (jobTime != "") {
                
                guard let jobDateTime = self.timeFormatter.date(from: jobTime) else {
                    continue
                }
                
                let job = CronJob( self.doJobs , executeAfter: jobDateTime, allowsSimultaneous: false, repeats: repeatJob == 1)
                //let job1 = CronJob( self.doJobs , executeAfter: now )
                
                cron?.add(job)
                //cron?.add(job1)
                
                self.allJobs.append(job)
                
                index = index + 1
            }
        }
        
    }
    
}
