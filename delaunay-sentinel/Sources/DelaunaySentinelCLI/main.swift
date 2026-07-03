import Foundation
import ArgumentParser
import DelaunaySentinel

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
struct DelaunaySentinelCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delaunay-sentinel",
        abstract: "Delaunay Sentinel - Malware Analyzer (Snocomm Security Suite)",
        discussion: """
        Analiza muestras y telemetría para clasificar malware y su peligrosidad.

        Misión: The Gunslinger
        Rol: malware-analyzer
        """,
        version: "3.0.0",
        subcommands: [Analyze.self],
        defaultSubcommand: Analyze.self
    )
}

extension DelaunaySentinelCLI {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "analyze",
            abstract: "Run malware analysis on sample/telemetry data."
        )

        @Option(name: .long, help: "Path to JSON file containing sample data (object of key→value).")
        var input: String?

        @Flag(name: .long, help: "Use the built-in sample dataset that produces interesting findings.")
        var sample = false

        @Flag(name: .long, help: "Read sample data as JSON from stdin.")
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

            let engine = DelaunaySentinel(config: config)

            let sampleData = try loadSampleData()
            Self.lastUsedData = sampleData

            if !json {
                printMissionHeader()
            }

            let result = engine.analyze(sampleData: sampleData)

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
            print("\(Console.cyan)🚀 Iniciando misión: The Gunslinger\(Console.reset)")
            print("\(Console.blue)🛡️  Rol: malware-analyzer\(Console.reset)")
            print(String(repeating: "─", count: 52))
        }

        private func loadSampleData() throws -> [String: Any] {
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

        private func outputJSON(_ result: AnalysisResult, engine: DelaunaySentinel) throws {
            let report = engine.analyzeMalware(sampleData: Self.lastUsedData ?? Self.sampleData)

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

        private func printHumanReport(result: AnalysisResult, engine: DelaunaySentinel) {
            print("\n\(Console.bold)[Informe de Misión]\(Console.reset)")
            print(String(repeating: "─", count: 30))

            let statusColor = result.status == "success" ? Console.green :
                              (result.status == "warning" ? Console.yellow : Console.red)
            print("Estado: \(Console.color(result.status.uppercased(), statusColor))")
            print("Mensaje: \(result.message)")

            // Fetch the real report for rich display
            let report = engine.analyzeMalware(sampleData: Self.lastUsedData ?? Self.sampleData)

            print("\n\(Console.bold)Total checks: \(report.totalChecks)\(Console.reset)")
            print("\(Console.bold)Alerts generadas: \(report.alertsCount)\(Console.reset)")

            if report.alertsCount > 0 {
                print("\n\(Console.bold)Hallazgos:\(Console.reset)")
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

        // A rich sample dataset based on the original Python example + extra signals
        private static let sampleData: [String: Any] = [
            "suspicious_imports": 9,
            "packed_binary": true,
            "network_callbacks": 5,
            "anti_vm_checks": true,
            "evasion_technique": 1,
            "high_entropy_packed": 0.92,
            "beaconing_to_c2": true,
            "normal_behavior_score": 0.12
        ]

        // Remember the data used in this run
        private static var lastUsedData: [String: Any]?
    }
}
