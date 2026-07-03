import Foundation
import AffineReplica

@main
struct LibraryDemo {
    static func main() {
        print("🔬 AffineReplica Library Usage Demo")
        print("====================================\n")

        // 1. Default configuration
        let engine = AffineReplica()

        print("Engine Info:")
        let info = engine.getInfo()
        for (key, value) in info {
            print("  \(key): \(value)")
        }
        print()

        // 2. Analyze with realistic data
        let telemetry: [String: Any] = [
            "beaconing_to_c2": true,
            "persistence_via_launchd": 0.82,
            "evasion_via_process_hollowing": true,
            "packed_upx_binary": "true",
            "high_entropy_section": 0.89,
            "suspicious_callback_url": true,
            "api_call_similarity": 0.93
        ]

        print("Analyzing telemetry data...\n")
        let result = engine.analyze(executionData: telemetry)

        print("Result:")
        print("  Status : \(result.status)")
        print("  Message: \(result.message)")
        print()

        // 3. Get full report by calling emulateBehavior directly (library power)
        let report = engine.emulateBehavior(executionData: telemetry)

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

        // 4. Demonstrate custom config
        print("\n--- Using stricter configuration ---\n")

        let strictEngine = AffineReplica(config: ModuleConfig(
            severityThreshold: "high",
            confidenceThreshold: 0.9,
            enableEnrichment: true
        ))

        let strictResult = strictEngine.analyze(executionData: telemetry)
        print("Strict mode status: \(strictResult.status)")
        print("Message: \(strictResult.message)")

        print("\n✅ Library usage demo completed successfully.")
    }
}
