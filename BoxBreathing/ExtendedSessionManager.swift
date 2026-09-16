import Foundation
import WatchKit

final class ExtendedSessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?
    private var onUnexpectedEnd: (() -> Void)?

    func start(onUnexpectedEnd: @escaping () -> Void) {
        stop()
        self.onUnexpectedEnd = onUnexpectedEnd
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        self.session = session
        session.start()
    }

    func stop() {
        onUnexpectedEnd = nil
        session?.invalidate()
        session = nil
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        DispatchQueue.main.async { [weak self] in self?.onUnexpectedEnd?() }
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard self?.session === extendedRuntimeSession else { return }
            self?.session = nil
            self?.onUnexpectedEnd?()
        }
    }
}
