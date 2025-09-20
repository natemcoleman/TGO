//
//  PrintingActivityViewModel.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/19/25.
//


// 1.
import Foundation
import ActivityKit

// 2.
@Observable
class PrintingActivityViewModel {
    // 3.
    var printName = "Benchy Boat"
    let printDuration: TimeInterval = 60
    var progress: Double = 0
    var printActivity: Activity<PrintingAttributes>? = nil
    var elapsedTime: TimeInterval = 0
    

    // 4.
    func startLiveActivity() {
        let attributes = PrintingAttributes(
            printName: printName,
            estimatedDuration: printDuration
        )
        
        let initialState = PrintingAttributes.ContentState(
            progress: 0.0,
            elapsedTime: 0,
            statusMessage: "Starting print..."
        )
        
        do {
            printActivity = try Activity.request(attributes: attributes, content: ActivityContent(state: initialState, staleDate: nil))
        } catch {
            print("Error starting live activity: \(error)")
        }
    }

    // 5.
    func updateLiveActivity() {
        let statusMessage: String
        
        if progress < 0.3 {
            statusMessage = "Heating bed and extruder..."
        } else if progress < 0.6 {
            statusMessage = "Printing base layers..."
        } else if progress < 0.9 {
            statusMessage = "Printing details..."
        } else {
            statusMessage = "Finishing print..."
        }
        
        let updatedState = PrintingAttributes.ContentState(
            progress: progress,
            elapsedTime: elapsedTime,
            statusMessage: statusMessage
        )
        
        Task {
            await printActivity?.update(using: updatedState)
        }
    }


    // 6.
    func endLiveActivity(success: Bool = false) {
        let finalMessage = success ? "Print completed successfully!" : "Print canceled"
        
        let finalState = PrintingAttributes.ContentState(
            progress: success ? 1.0 : progress,
            elapsedTime: elapsedTime,
            statusMessage: finalMessage
        )
        
        Task {
            //await printActivity?.end(using: finalState, dismissalPolicy: .default)
            await printActivity?.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
    }
}