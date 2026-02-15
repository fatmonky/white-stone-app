import SwiftUI

struct StoneIcon: View {
    let type: StoneType
    let size: CGFloat

    private var isLarge: Bool { size >= 60 }

    var body: some View {
        if isLarge {
            largeStone
        } else {
            smallStone
        }
    }

    // MARK: - Small stone (timeline dots, counts)
    private var smallStone: some View {
        Circle()
            .fill(type == .white ? Color.white : Color.black)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .frame(width: size, height: size)
    }

    // MARK: - Large textured stone
    private var largeStone: some View {
        let baseColor = type == .white ? Color.white : Color.black
        let highlightColor = type == .white ? Color.white : Color(white: 0.25)
        let shadowColor = type == .white ? Color(white: 0.75) : Color(white: 0.0)
        let edgeColor = Color(white: 0.5)

        return Circle()
            // Base gradient for 3D curvature — light from top-left
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [highlightColor, baseColor, shadowColor]),
                    center: .init(x: 0.35, y: 0.3),
                    startRadius: size * 0.05,
                    endRadius: size * 0.6
                )
            )
            // Subtle specular highlight
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                (type == .white ? Color.white : Color(white: 0.4)).opacity(0.6),
                                Color.clear
                            ]),
                            center: .init(x: 0.3, y: 0.25),
                            startRadius: 0,
                            endRadius: size * 0.25
                        )
                    )
            )
            // Inner shadow around edges for depth
            .overlay(
                Circle()
                    .stroke(edgeColor, lineWidth: 0.05)
            )
            // Fine surface texture using concentric subtle rings
            .overlay(
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                baseColor.opacity(0.0),
                                baseColor.opacity(0.04),
                                baseColor.opacity(0.0),
                                baseColor.opacity(0.03),
                                baseColor.opacity(0.0),
                                baseColor.opacity(0.05),
                                baseColor.opacity(0.0),
                            ]),
                            center: .init(x: 0.45, y: 0.45)
                        )
                    )
            )
            // Outer edge definition
            .overlay(
                Circle()
                    .stroke(
                        Color(white: 0.5),
                        lineWidth: 0.05
                    )
            )
            // Drop shadow for lift — tighter for crispness
            .shadow(
                color: Color.black.opacity(type == .white ? 0.2 : 0.5),
                radius: size * 0.02,
                x: size * 0.01,
                y: size * 0.015
            )
            .frame(width: size, height: size)
    }
}
