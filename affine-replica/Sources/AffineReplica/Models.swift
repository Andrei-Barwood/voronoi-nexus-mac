import Foundation

/// Represents a single detection finding from the emulation engine.
public struct DetectionFinding: Codable, Equatable, Sendable {
    public let indicator: String
    public let category: String
    public let severity: String
    public let confidence: Double
    public let recommendation: String?

    public init(
        indicator: String,
        category: String,
        severity: String,
        confidence: Double,
        recommendation: String? = nil
    ) {
        self.indicator = indicator
        self.category = category
        self.severity = severity
        self.confidence = confidence
        self.recommendation = recommendation
    }
}

/// Report produced by the emulation / detection run.
public struct DetectionReport: Codable, Sendable {
    public let totalChecks: Int
    public let alertsCount: Int
    public let findings: [DetectionFinding]
    public let summary: [String: String]

    public init(
        totalChecks: Int,
        alertsCount: Int,
        findings: [DetectionFinding],
        summary: [String: String]
    ) {
        self.totalChecks = totalChecks
        self.alertsCount = alertsCount
        self.findings = findings
        self.summary = summary
    }
}

/// Top level result returned by analyze().
public struct AnalysisResult: Codable, Sendable {
    public let status: String
    public let message: String
    public let data: [String: String]?   // Will contain serialized report for simplicity in JSON output
    public let errors: [String]?

    public init(
        status: String,
        message: String,
        data: [String: String]? = nil,
        errors: [String]? = nil
    ) {
        self.status = status
        self.message = message
        self.data = data
        self.errors = errors
    }
}

/// Configuration accepted by the engine.
public struct ModuleConfig: Sendable {
    public var severityThreshold: String
    public var confidenceThreshold: Double
    public var enableEnrichment: Bool

    public init(
        severityThreshold: String = "medium",
        confidenceThreshold: Double = 0.7,
        enableEnrichment: Bool = true
    ) {
        self.severityThreshold = severityThreshold
        self.confidenceThreshold = confidenceThreshold
        self.enableEnrichment = enableEnrichment
    }
}
