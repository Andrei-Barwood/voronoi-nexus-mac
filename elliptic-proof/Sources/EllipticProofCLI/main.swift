import Foundation
import ArgumentParser
import EllipticProof

struct Console {
    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
    static let red = "\u{001B}[31m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
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

@main
struct EllipticProofCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "elliptic-proof",
        abstract: "Elliptic Proof - Crypto Analyzer (Snocomm Security Suite)",
        discussion: """
        Evalúa implementaciones criptográficas y configuraciones de claves.

        Misión: Good Intentions
        Rol: crypto-analyzer
        """,
        version: "3.0.0",
        subcommands: [Analyze.self],
        defaultSubcommand: Analyze.self
    )
}

extension EllipticProofCLI {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "analyze",
            abstract: "Run cryptographic implementation and key config analysis."
        )

        @Option(name: .long, help: "Path to JSON file containing crypto data.")
        var input: String?

        @Flag(name: .long, help: "Use built-in sample dataset.")
        var sample = false

        @Flag(name: .long, help: "Read data from stdin.")
        var stdin = false

        @Option(name: .long, help: "Minimum severity (critical|high|medium|low).")
        var severityThreshold: String = "medium"

        @Option(name: .long, help: "Minimum confidence score [0.0-1.0].")
        var confidenceThreshold: Double = 0.7

        @Flag(name: .long, help: "Disable enrichment.")
        var noEnrichment = false

        @Flag(name: .long, help: "Output JSON.")
        var json = false

        func run() throws {
            let config = ModuleConfig(
                severityThreshold: severityThreshold,
                confidenceThreshold: confidenceThreshold,
                enableEnrichment: !noEnrichment
            )

            let engine = EllipticProof(config: config)
            let cryptoData = try loadCryptoData()

            Self.lastUsedData = cryptoData

            if !json {
                print("\(Console.cyan)🚀 Iniciando misión: Good Intentions\(Console.reset)")
                print("\(Console.blue)🛡️  Rol: crypto-analyzer\(Console.reset)")
                print(String(repeating: "─", count: 52))
            }

            let result = engine.analyze(cryptoData: cryptoData)

            if json {
                try outputJSON(result, engine: engine)
            } else {
                printHumanReport(result: result, engine: engine)
            }

            switch result.status {
            case "success": throw ExitCode.success
            case "warning": throw ExitCode(1)
            default: throw ExitCode(2)
            }
        }

        private func loadCryptoData() throws -> [String: Any] {
            if sample { return Self.sampleData }
            if let path = input {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try parseJSON(data)
            }
            if stdin || isatty(STDIN_FILENO) == 0 {
                let data = FileHandle.standardInput.readDataToEndOfFile()
                if !data.isEmpty { return try parseJSON(data) }
            }
            print("\(Console.yellow)(No input — using built-in sample)\(Console.reset)\n")
            return Self.sampleData
        }

        private func parseJSON(_ data: Data) throws -> [String: Any] {
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ValidationError("Input must be a JSON object.")
            }
            return obj
        }

        private func outputJSON(_ result: AnalysisResult, engine: EllipticProof) throws {
            let report = engine.analyzeCryptography(cryptoData: Self.lastUsedData ?? Self.sampleData)

            struct JFinding: Codable { let indicator, category, severity: String; let confidence: Double; let recommendation: String? }
            struct JReport: Codable { let total_checks, alerts_count: Int; let findings: [JFinding]; let summary: [String: String] }
            struct JOut: Codable { let status, message: String; let data: JReport; let errors: [String] }

            let jFindings = report.findings.map { JFinding(indicator: $0.indicator, category: $0.category, severity: $0.severity, confidence: Double(String(format: "%.2f", $0.confidence)) ?? $0.confidence, recommendation: $0.recommendation) }
            let jReport = JReport(total_checks: report.totalChecks, alerts_count: report.alertsCount, findings: jFindings, summary: report.summary)
            let jOut = JOut(status: result.status, message: result.message, data: jReport, errors: result.errors ?? [])

            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            print(String(data: try enc.encode(jOut), encoding: .utf8)!)
        }

        private func printHumanReport(result: AnalysisResult, engine: EllipticProof) {
            print("\n\(Console.bold)[Informe de Misión]\(Console.reset)")
            print(String(repeating: "─", count: 30))
            let col = result.status == "success" ? Console.green : (result.status == "warning" ? Console.yellow : Console.red)
            print("Estado: \(Console.color(result.status.uppercased(), col))")
            print("Mensaje: \(result.message)")

            let report = engine.analyzeCryptography(cryptoData: Self.lastUsedData ?? Self.sampleData)
            print("\nTotal checks: \(report.totalChecks)")
            print("Alerts generadas: \(report.alertsCount)")

            if report.alertsCount > 0 {
                print("\n\(Console.bold)Hallazgos:\(Console.reset)")
                let sorted = report.findings.sorted {
                    let r0 = ["critical":0,"high":1,"medium":2,"low":3][$0.severity, default:9]
                    let r1 = ["critical":0,"high":1,"medium":2,"low":3][$1.severity, default:9]
                    return r0 != r1 ? r0 < r1 : $0.confidence > $1.confidence
                }
                for (i, f) in sorted.enumerated() {
                    let sev = Console.severityColor(f.severity, f.severity.uppercased())
                    print("  \(i+1). \(Console.bold)\(f.indicator)\(Console.reset)")
                    print("     • Severidad : \(sev)")
                    print("     • Confianza : \(String(format: "%.2f", f.confidence))")
                    print("     • Recomendación: \(f.recommendation ?? "")")
                }
            } else {
                print("\n\(Console.green)✓ No se generaron alertas.\(Console.reset)")
            }
            print(String(repeating: "─", count: 52))
            print("🏁 Misión completada.")
        }

        private static let sampleData: [String: Any] = [
            "deprecated_ciphers": 2,
            "weak_key_detected": true,
            "tls_misconfigurations": 4,
            "signature_validation_issues": 1,
            "insecure_curve": true,
            "missing_key_rotation": 0.88,
            "weak_hash_algorithm": true,
            "packed_crypto_implementation": true,
            "evasion_in_key_exchange": true
        ]

        private static var lastUsedData: [String: Any]?
    }
}
