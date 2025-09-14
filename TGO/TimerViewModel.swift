//
//  to.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/13/25.
//


import Foundation
import Combine

// An enum to manage the different states of the timer.
enum RunState {
    case notStarted
    case running
    case paused
}

class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var elapsedTime: TimeInterval = 0
    @Published var runState: RunState = .notStarted
    @Published var splits: [TimeInterval] = []

    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0

    // MARK: - Public Methods
    func start() {
        reset() // Clear any previous run
        runState = .running
        startTime = Date()
        startTimer()
    }

    func pause() {
        timer?.invalidate()
        // Add the time elapsed since the last start/resume to the total.
        accumulatedTime += Date().timeIntervalSince(startTime ?? Date())
        runState = .paused
    }

    func resume() {
        startTime = Date() // Reset the start time for the new interval
        runState = .running
        startTimer()
    }
    
    func split() {
        guard runState == .running else { return }
        splits.append(currentElapsedTime())
    }

    func finish() {
        timer?.invalidate()
        if runState == .running {
            splits.append(currentElapsedTime())
        }
        runState = .notStarted
        // Here you would add logic to save the 'splits' array if needed.
    }
    
    func reset() {
        timer?.invalidate()
        runState = .notStarted
        elapsedTime = 0
        accumulatedTime = 0
        splits.removeAll()
    }

    // MARK: - Private Helpers
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime = self?.currentElapsedTime() ?? 0
        }
    }
    
    // Calculates the total elapsed time by adding the accumulated time
    // and the time since the last resume.
    private func currentElapsedTime() -> TimeInterval {
        return accumulatedTime + Date().timeIntervalSince(startTime ?? Date())
    }
}
