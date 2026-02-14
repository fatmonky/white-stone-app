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
        let edgeColor = type == .white ? Color(white: 0.82) : Color(white: 0.08)

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
                    .stroke(edgeColor, lineWidth: size * 0.02)
                    .blur(radius: size * 0.015)
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
                        LinearGradient(
                            colors: [
                                (type == .white ? Color(white: 0.9) : Color(white: 0.15)),
                                (type == .white ? Color(white: 0.7) : Color(white: 0.0)),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            // Drop shadow for lift
            .shadow(
                color: Color.black.opacity(type == .white ? 0.25 : 0.5),
                radius: size * 0.04,
                x: size * 0.02,
                y: size * 0.03
            )
            .frame(width: size, height: size)
    }
}
