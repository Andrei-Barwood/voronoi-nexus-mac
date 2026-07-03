import Foundation
import ArgumentParser
import AffineReplica
import Darwin // for isatty and STDIN_FILENO

// MARK: - ANSI Colors (no external deps)
struct Console {
    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
    static let red = "\u{001B}[31m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
    static let magenta = "\u{001B}[35m"
    static let cyan = "\u{001B}[36m"

    static func color(_ text: String, _ colorCode: String) -> String {
        "\(colorCode)\(text)\(reset)"
    }

    static func severityColor(_ severity: String, _ text: String) -> String {
        switch severity.lowercased() {
        case "critical": return color(text, red + bold)
        case "high":     return color(text, red)
        case "medium":   return color(text, yellow)
        case "low":      return color(text, green)
        default:         return text
        }
    }
}

// MARK: - CLI

@main
struct AffineReplicaCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "affine-replica",
        abstract: "Affine Replica - Emulation Engine (Snocomm Security Suite)",
        discussion: """
        Emula ejecución de artefactos para inferir intención y riesgos.

        Misión: American Distillation
        Rol: emulation-engine
        """,
        version: "3.0.0",
        subcommands: [Analyze.self],
        defaultSubcommand: Analyze.self
    )
}

extension AffineReplicaCLI {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "analyze",
            abstract: "Run emulation analysis on execution/behavior data."
        )

        @Option(name: .long, help: "Path to JSON file containing execution data (object of key→value).")
        var input: String?

        @Flag(name: .long, help: "Use the built-in sample dataset that produces interesting findings.")
        var sample = false

        @Flag(name: .long, help: "Read execution data as JSON from stdin.")
        var stdin = false

        @Option(name: .long, help: "Minimum severity to report (critical|high|medium|low).")
        var severityThreshold: String = "medium"

        @Option(name: .long, help: "Minimum confidence score [0.0 - 1.0].")
        var confidenceThreshold: Double = 0.7

        @Flag(name: .long, help: "Disable enrichment (only affects summary).")
        var noEnrichment = false

        @Flag(name: .long, help: "Output machine-readable JSON instead of human report.")
        var json = false

        func run() throws {
            let config = ModuleConfig(
                severityThreshold: severityThreshold,
                confidenceThreshold: confidenceThreshold,
                enableEnrichment: !noEnrichment
            )

            let engine = AffineReplica(config: config)

            let executionData = try loadExecutionData()
            Self.lastUsedData = executionData

            if !json {
                printMissionHeader()
            }

            let result = engine.analyze(executionData: executionData)

            if json {
                try outputJSON(result, engine: engine)
            } else {
                printHumanReport(result: result, engine: engine)
            }

            // Exit codes as specified in prompt
            switch result.status {
            case "success":
                throw ExitCode.success
            case "warning":
                throw ExitCode(1)
            default:
                throw ExitCode(2)
            }
        }

        private func printMissionHeader() {
            print("\(Console.cyan)🚀 Iniciando misión: American Distillation\(Console.reset)")
            print("\(Console.blue)🛡️  Rol: emulation-engine\(Console.reset)")
            print(String(repeating: "─", count: 52))
        }

        private func loadExecutionData() throws -> [String: Any] {
            if sample {
                return Self.sampleData
            }

            if let path = input {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url)
                return try parseJSONDictionary(data)
            }

            if stdin || isatty(STDIN_FILENO) == 0 {
                let data = FileHandle.standardInput.readDataToEndOfFile()
                if data.isEmpty {
                    throw ValidationError("No data received on stdin.")
                }
                return try parseJSONDictionary(data)
            }

            // Default: use safe sample if nothing provided
            print("\(Console.yellow)(No input provided — using built-in sample data)\(Console.reset)\n")
            return Self.sampleData
        }

        private func parseJSONDictionary(_ data: Data) throws -> [String: Any] {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ValidationError("Input must be a JSON object (dictionary of string keys).")
            }
            return jsonObject
        }

        private func outputJSON(_ result: AnalysisResult, engine: AffineReplica) throws {
            // For richer JSON we re-run to get the full report and serialize it properly
            let report = engine.emulateBehavior(executionData: Self.lastUsedData ?? Self.sampleData)

            struct JSONFinding: Codable {
                let indicator: String
                let category: String
                let severity: String
                let confidence: Double
                let recommendation: String?
            }

            struct JSONReport: Codable {
                let total_checks: Int
                let alerts_count: Int
                let findings: [JSONFinding]
                let summary: [String: String]
            }

            struct JSONOutput: Codable {
                let status: String
                let message: String
                let data: JSONReport
                let errors: [String]
            }

            let jsonFindings = report.findings.map {
                JSONFinding(
                    indicator: $0.indicator,
                    category: $0.category,
                    severity: $0.severity,
                    confidence: Double(String(format: "%.2f", $0.confidence)) ?? $0.confidence,
                    recommendation: $0.recommendation
                )
            }

            let jsonReport = JSONReport(
                total_checks: report.totalChecks,
                alerts_count: report.alertsCount,
                findings: jsonFindings,
                summary: report.summary
            )

            let jsonOutput = JSONOutput(
                status: result.status,
                message: result.message,
                data: jsonReport,
                errors: result.errors ?? []
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(jsonOutput)
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }

        private func printHumanReport(result: AnalysisResult, engine: AffineReplica) {
            print("\n\(Console.bold)[Informe de Misión]\(Console.reset)")
            print(String(repeating: "─", count: 30))

            let statusColor = result.status == "success" ? Console.green :
                              (result.status == "warning" ? Console.yellow : Console.red)
            print("Estado: \(Console.color(result.status.uppercased(), statusColor))")
            print("Mensaje: \(result.message)")

            // Fetch the real report for rich display
            let report = engine.emulateBehavior(executionData: Self.lastUsedData ?? Self.sampleData)

            print("\n\(Console.bold)Total checks: \(report.totalChecks)\(Console.reset)")
            print("\(Console.bold)Alerts generadas: \(report.alertsCount)\(Console.reset)")

            if report.alertsCount > 0 {
                print("\n\(Console.bold)Hallazgos:\(Console.reset)")
                // Sort for deterministic nice output: critical first, then by descending confidence
                let sortedFindings = report.findings.sorted {
                    let rank0 = ["critical":0, "high":1, "medium":2, "low":3][$0.severity, default: 9]
                    let rank1 = ["critical":0, "high":1, "medium":2, "low":3][$1.severity, default: 9]
                    if rank0 != rank1 { return rank0 < rank1 }
                    return $0.confidence > $1.confidence
                }
                for (idx, finding) in sortedFindings.enumerated() {
                    let sev = Console.severityColor(finding.severity, finding.severity.uppercased())
                    print("  \(idx + 1). \(Console.bold)\(finding.indicator)\(Console.reset)")
                    print("     • Severidad : \(sev)")
                    print("     • Confianza : \(String(format: "%.2f", finding.confidence))")
                    print("     • Categoría : \(finding.category)")
                    if let rec = finding.recommendation {
                        print("     • Recomendación: \(rec)")
                    }
                    print()
                }
            } else {
                print("\n\(Console.green)✓ No se generaron alertas por encima del umbral.\(Console.reset)")
            }

            print(String(repeating: "─", count: 52))
            print("🏁 Misión completada.")
        }

        // MARK: - Sample Data

        // A rich sample dataset that produces multiple findings (chosen to exercise the logic)
        private static let sampleData: [String: Any] = [
            "beaconing_activity": true,
            "persistence_mechanism": 0.95,
            "evasion_technique_detected": true,
            "packed_binary": "true",
            "api_sequence_similarity": 0.91,
            "syscall_profile_risk": 0.82,
            "suspicious_entropy": 0.78,
            "callback_channel": 1,
            "mass_deletion_signals": 0.6,
            "low_risk_noise": 0.3
        ]

        // Remember the data used in this run so --json and pretty printer can access rich report
        private static var lastUsedData: [String: Any]?
    }
}
