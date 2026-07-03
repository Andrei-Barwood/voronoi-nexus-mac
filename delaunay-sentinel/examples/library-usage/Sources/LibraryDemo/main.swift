import Foundation
import DelaunaySentinel

@main
struct LibraryDemo {
    static func main() {
        print("🔬 DelaunaySentinel Library Usage Demo")
        print("====================================\n")

        // 1. Default configuration
        let engine = DelaunaySentinel()

        print("Engine Info:")
        let info = engine.getInfo()
        for (key, value) in info {
            print("  \(key): \(value)")
        }
        print()

        // 2. Analyze with realistic malware sample data
        let sample: [String: Any] = [
            "packed_upx": true,
            "evasion_process_hollowing": true,
            "beaconing_activity": true,
            "anti_analysis_vm": true,
            "high_entropy_code": 0.91,
            "callback_to_c2": true,
            "suspicious_api_imports": 12,
            "persistence_registry": 0.78
        ]

        print("Analyzing malware sample data...\n")
        let result = engine.analyze(sampleData: sample)

        print("Result:")
        print("  Status : \(result.status)")
        print("  Message: \(result.message)")
        print()

        // 3. Get full report by calling analyzeMalware directly (library power)
        let report = engine.analyzeMalware(sampleData: sample)

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

        let strictEngine = DelaunaySentinel(config: ModuleConfig(
            severityThreshold: "high",
            confidenceThreshold: 0.9,
            enableEnrichment: true
        ))

        let strictResult = strictEngine.analyze(sampleData: sample)
        print("Strict mode status: \(strictResult.status)")
        print("Message: \(strictResult.message)")

        print("\n✅ Library usage demo completed successfully.")
    }
}
