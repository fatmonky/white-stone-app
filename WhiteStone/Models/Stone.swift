import Foundation
import SwiftData

enum StoneType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case white
    case black
}

protocol StoneTagOption: Identifiable, Hashable {
    var displayName: String { get }
}

enum StoneRoot: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case sensual
    case illWill
    case harming
    case renunciation
    case kindness
    case harmlessness

    var displayName: String {
        switch self {
        case .sensual: return "sensual desire"
        case .illWill: return "ill will"
        case .harming: return "harming"
        case .renunciation: return "renunciation"
        case .kindness: return "kindness"
        case .harmlessness: return "harmlessness"
        }
    }

    static func allowed(for type: StoneType) -> [StoneRoot] {
        switch type {
        case .white:
            return [.renunciation, .kindness, .harmlessness]
        case .black:
            return [.sensual, .illWill, .harming]
        }
    }
}

extension StoneRoot: StoneTagOption {}

enum StoneIntensity: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case strong
    case weak

    var displayName: String {
        rawValue
    }
}

extension StoneIntensity: StoneTagOption {}

@Model
final class Stone {
    var type: StoneType
    var timestamp: Date {
        didSet {
            dayKey = DateHelpers.dayKey(for: timestamp)
        }
    }
    var note: String
    var dayKey: String // "yyyy-MM-dd" for efficient filtering
    var root: StoneRoot?
    var rootTagsRawValue: String?
    var rootDescriptor: String?
    var intensity: StoneIntensity?

    init(
        type: StoneType,
        note: String = "",
        timestamp: Date = .now,
        root: StoneRoot? = nil,
        roots: [StoneRoot] = [],
        rootDescriptor: String = "",
        intensity: StoneIntensity? = nil
    ) {
        self.type = type
        self.timestamp = timestamp
        self.note = note
        self.dayKey = DateHelpers.dayKey(for: timestamp)
        self.root = root ?? roots.first
        self.rootTagsRawValue = roots.map(\.rawValue).joined(separator: ",")
        self.rootDescriptor = rootDescriptor
        self.intensity = intensity
    }

    var roots: [StoneRoot] {
        get {
            let parsedRoots = (rootTagsRawValue ?? "")
                .split(separator: ",")
                .compactMap { StoneRoot(rawValue: String($0)) }
            if parsedRoots.isEmpty, let root {
                return [root]
            }
            return parsedRoots
        }
        set {
            rootTagsRawValue = newValue.map(\.rawValue).joined(separator: ",")
            root = newValue.first
        }
    }

    var rootDisplayNames: [String] {
        var names = roots.map(\.displayName)
        names.append(contentsOf: customRootDescriptors)
        return names
    }

    var customRootDescriptors: [String] {
        (rootDescriptor ?? "")
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var tagSummaryText: String? {
        let labels = rootDisplayNames + [intensity?.displayName].compactMap { $0 }
        guard !labels.isEmpty else { return nil }
        return labels.joined(separator: " · ")
    }
}
