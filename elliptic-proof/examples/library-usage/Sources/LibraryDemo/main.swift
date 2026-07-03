import Foundation
import EllipticProof

@main
struct LibraryDemo {
    static func main() {
        print("🔬 EllipticProof Library Usage Demo")
        print("===================================\n")

        let engine = EllipticProof()

        print("Engine Info:")
        for (key, value) in engine.getInfo() {
            print("  \(key): \(value)")
        }
        print()

        let cryptoData: [String: Any] = [
            "weak_key_detected": true,
            "deprecated_ciphers": 3,
            "tls_misconfigurations": 5,
            "insecure_curve": true,
            "signature_validation_issues": 2
        ]

        print("Analyzing crypto data...\n")
        let result = engine.analyze(cryptoData: cryptoData)

        print("Result:")
        print("  Status : \(result.status)")
        print("  Message: \(result.message)")
        print()

        let report = engine.analyzeCryptography(cryptoData: cryptoData)

        print("Detailed Report:")
        print("  Total checks : \(report.totalChecks)")
        print("  Alerts       : \(report.alertsCount)")
        print()

        if !report.findings.isEmpty {
            print("Findings:")
            for finding in report.findings {
                let conf = String(format: "%.2f", finding.confidence)
                print("  • [\(finding.severity.uppercased())] \(finding.indicator)")
                print("    Confidence: \(conf)  |  Recommendation: \(finding.recommendation ?? "N/A")")
            }
        }

        print("\n--- Using stricter configuration ---\n")
        let strict = EllipticProof(config: ModuleConfig(
            severityThreshold: "high",
            confidenceThreshold: 0.9
        ))
        let strictResult = strict.analyze(cryptoData: cryptoData)
        print("Strict mode status: \(strictResult.status)")

        print("\n✅ Library usage demo completed successfully.")
    }
}
