import Foundation

/// DelaunaySentinel - Malware Analyzer (Swift port)
///
/// Analiza muestras y telemetría para clasificar malware y su peligrosidad.
/// Misión: The Gunslinger
/// Rol: malware-analyzer
public final class DelaunaySentinel: Sendable {
    public let name = "Delaunay Sentinel"
    public let mission = "The Gunslinger"
    public let role = "malware-analyzer"

    public let severityThreshold: String
    public let confidenceThreshold: Double
    public let enableEnrichment: Bool

    private let severityRank: [String: Int] = [
        "critical": 0,
        "high": 1,
        "medium": 2,
        "low": 3
    ]

    private let riskSignals: [String: [String]] = [
        "critical": ["critical", "mass", "deleted", "beaconing", "persistence"],
        "high": ["suspicious", "anomaly", "evasion", "packed", "callback"],
        "medium": ["warning", "irregular", "mismatch", "cluster", "entropy"]
    ]

    public init(config: ModuleConfig = ModuleConfig()) {
        self.severityThreshold = config.severityThreshold
        self.confidenceThreshold = config.confidenceThreshold
        self.enableEnrichment = config.enableEnrichment
    }

    /// Normalizes any input signal into a [0, 1] confidence score.
    private func normalizeSignal(key: String, value: Any) -> Double {
        if let boolValue = value as? Bool {
            return boolValue ? 1.0 : 0.0
        }
        if let num = value as? NSNumber {
            let doubleVal = num.doubleValue
            if doubleVal <= 1.0 {
                return doubleVal
            }
            return min(doubleVal / 100.0, 1.0)
        }
        if let str = value as? String {
            let lower = str.lowercased()
            if ["true", "yes", "high", "critical"].contains(lower) {
                return 1.0
            }
            return 0.3
        }
        return 0.0
    }

    /// Core malware analysis logic. Replicates the original Python behavior exactly.
    public func analyzeMalware(sampleData: [String: Any]) -> DetectionReport {
        var findings: [DetectionFinding] = []
        let totalChecks = sampleData.count

        let thresholdRank = severityRank[severityThreshold.lowercased()] ?? 2

        for (rawKey, rawValue) in sampleData {
            let score = normalizeSignal(key: rawKey, value: rawValue)
            let keyLower = rawKey.lowercased()

            if score < confidenceThreshold {
                continue
            }

            var severity = "low"

            if riskSignals["critical"]!.contains(where: { keyLower.contains($0) }) {
                severity = "critical"
            } else if riskSignals["high"]!.contains(where: { keyLower.contains($0) }) {
                severity = "high"
            } else if riskSignals["medium"]!.contains(where: { keyLower.contains($0) }) {
                severity = "medium"
            } else {
                severity = "low"
            }

            if let sevRank = severityRank[severity], sevRank > thresholdRank {
                continue
            }

            let recommendation: String
            if ["critical", "high"].contains(severity) {
                recommendation = "Escalar al SOC y activar playbook de contención"
            } else {
                recommendation = "Monitorear y correlacionar con telemetría adicional"
            }

            findings.append(
                DetectionFinding(
                    indicator: rawKey,
                    category: role,
                    severity: severity,
                    confidence: (score * 100).rounded() / 100,
                    recommendation: recommendation
                )
            )
        }

        let alertsCount = findings.count

        let summary: [String: String] = [
            "engine": name,
            "role": role,
            "enrichment_enabled": String(enableEnrichment),
            "severity_threshold": severityThreshold,
            "confidence_threshold": String(format: "%.2f", confidenceThreshold)
        ]

        return DetectionReport(
            totalChecks: totalChecks,
            alertsCount: alertsCount,
            findings: findings,
            summary: summary
        )
    }

    /// Main analysis entry point. Matches original DelaunaySentinel.analyze()
    public func analyze(sampleData: [String: Any]? = nil) -> AnalysisResult {
        guard let data = sampleData, !data.isEmpty else {
            return AnalysisResult(
                status: "error",
                message: "No input data provided",
                data: nil,
                errors: ["missing_input"]
            )
        }

        let report = analyzeMalware(sampleData: data)
        let status = report.alertsCount > 0 ? "warning" : "success"
        let message = "Analysis completed: \(report.alertsCount) alerts generated"

        // For JSON compatibility we embed a simplified representation of the report
        let reportDict: [String: String] = [
            "total_checks": String(report.totalChecks),
            "alerts_count": String(report.alertsCount),
            "findings_count": String(report.findings.count),
            "summary_engine": report.summary["engine"] ?? "",
            "summary_role": report.summary["role"] ?? ""
        ]

        return AnalysisResult(
            status: status,
            message: message,
            data: reportDict,
            errors: nil
        )
    }

    public func validate(_ data: Any?) -> Bool {
        guard let dict = data as? [String: Any] else { return false }
        return !dict.isEmpty
    }

    public func getInfo() -> [String: String] {
        return [
            "name": name,
            "mission": mission,
            "role": role,
            "status": "Production",
            "severity_threshold": severityThreshold,
            "confidence_threshold": String(format: "%.2f", confidenceThreshold)
        ]
    }
}
