import Foundation
import HealthKit

struct HeartRateComparison {
    let before: Int?
    let after: Int?
    let saved: Bool
}

final class HeartRateWorkout: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    private let store = HKHealthStore()
    private let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var workout: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var startDate: Date?
    private var beforeEnd: Date?
    private var afterStart: Date?
    var onUnexpectedEnd: (() -> Void)?

    func start(completion: @escaping (Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(WorkoutError.unavailable)
            return
        }
        store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [heartRate]) { [weak self] authorized, error in
            guard let self else { return }
            guard authorized, error == nil,
                  self.store.authorizationStatus(for: .workoutType()) == .sharingAuthorized else {
                DispatchQueue.main.async { completion(error ?? WorkoutError.authorization) }
                return
            }
            do {
                let config = HKWorkoutConfiguration()
                config.activityType = .mindAndBody
                config.locationType = .indoor
                let workout = try HKWorkoutSession(healthStore: self.store, configuration: config)
                let builder = workout.associatedWorkoutBuilder()
                workout.delegate = self
                builder.delegate = self
                builder.dataSource = HKLiveWorkoutDataSource(healthStore: self.store, workoutConfiguration: config)
                self.workout = workout
                self.builder = builder
                let date = Date()
                self.startDate = date
                workout.startActivity(with: date)
                builder.beginCollection(withStart: date) { success, error in
                    if !success { workout.end() }
                    DispatchQueue.main.async { completion(success ? nil : (error ?? WorkoutError.startFailed)) }
                }
            } catch {
                DispatchQueue.main.async { completion(error) }
            }
        }
    }

    func markBeforeEnd() { beforeEnd = Date() }
    func markAfterStart() { afterStart = Date() }

    func finish(completion: @escaping (HeartRateComparison) -> Void) {
        guard let workout, let builder, let startDate else {
            completion(HeartRateComparison(before: nil, after: nil, saved: false))
            return
        }
        let endDate = Date()
        workout.end()
        builder.endCollection(withEnd: endDate) { [weak self] _, _ in
            builder.finishWorkout { savedWorkout, _ in
                guard let self else { return }
                self.readHeartRates(from: startDate, to: endDate) { samples in
                    let before = self.average(samples, from: startDate, to: self.beforeEnd)
                    let after = self.average(samples, from: self.afterStart, to: endDate)
                    DispatchQueue.main.async {
                        completion(HeartRateComparison(before: before, after: after, saved: savedWorkout != nil))
                    }
                }
            }
        }
    }

    private func readHeartRates(from start: Date, to end: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: heartRate, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            completion(samples as? [HKQuantitySample] ?? [])
        }
        store.execute(query)
    }

    private func average(_ samples: [HKQuantitySample], from start: Date?, to end: Date?) -> Int? {
        guard let start, let end else { return nil }
        let values = samples.filter { $0.startDate >= start && $0.startDate <= end }
            .map { $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) }
        guard !values.isEmpty else { return nil }
        return Int((values.reduce(0, +) / Double(values.count)).rounded())
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .ended, fromState != .ended {
            DispatchQueue.main.async { self.onUnexpectedEnd?() }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async { self.onUnexpectedEnd?() }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {}

    private enum WorkoutError: LocalizedError {
        case unavailable, authorization, startFailed
        var errorDescription: String? {
            switch self {
            case .unavailable: "Health data is unavailable on this watch."
            case .authorization: "Allow workout saving in Health to start a session."
            case .startFailed: "The workout could not start."
            }
        }
    }
}
