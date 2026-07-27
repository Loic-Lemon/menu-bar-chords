import SwiftUI
import ChordsLib

struct FretboardView: View {
    let frets: [Int?]
    let fingers: [Int?]
    let barres: [Barre]
    let baseFret: Int
    var rootString: Int?
    var highlightFret: Int?
    var highlightString: Int?

    init(
        frets: [Int?],
        fingers: [Int?],
        barres: [Barre] = [],
        baseFret: Int = 1,
        rootString: Int? = nil,
        highlightFret: Int? = nil,
        highlightString: Int? = nil
    ) {
        self.frets = frets
        self.fingers = fingers
        self.barres = barres
        self.baseFret = baseFret
        self.rootString = rootString
        self.highlightFret = highlightFret
        self.highlightString = highlightString
    }

    private let stringCount = 6
    private let fretCount = 3
    private let leftMargin: CGFloat = 28
    private let rightMargin: CGFloat = 28
    private var colWidth: CGFloat { (frameWidth - leftMargin - rightMargin) / CGFloat(fretCount) }
    private let stringSpacing: CGFloat = 16
    private let topMargin: CGFloat = 28
    private let bottomMargin: CGFloat = 22
    private let frameWidth: CGFloat = 260
    private var frameHeight: CGFloat {
        topMargin + CGFloat(stringCount - 1) * stringSpacing + bottomMargin
    }

    private var noteDiameter: CGFloat { colWidth * 0.45 }
    private var dotRadius: CGFloat { noteDiameter / 2 }

    var body: some View {
        Canvas { context, size in
            let baseY = topMargin
            let baseX = leftMargin

            drawNutOrFretLines(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawStringLines(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawFretNumber(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawStringMarkers(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawStringFretValues(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawBarres(context: &context, baseX: baseX, baseY: baseY, size: size)
            drawFingerDots(context: &context, baseX: baseX, baseY: baseY, size: size)
        }
        .frame(width: frameWidth, height: frameHeight)
    }

    private func drawStringFretValues(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        let x = frameWidth - rightMargin / 2 + 4
        for string in 0..<stringCount {
            let fretValue = frets.indices.contains(string) ? frets[string] : nil
            let y = stringY(string, baseY: baseY)
            
            let text: String
            if let f = fretValue {
                text = "\(f)"
            } else {
                text = "X"
            }
            
            context.draw(
                Text(text)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(fretValue == nil ? .red : .primary),
                at: CGPoint(x: x, y: y)
            )
        }
    }

    private func stringY(_ index: Int, baseY: CGFloat) -> CGFloat {
        baseY + CGFloat(index) * stringSpacing
    }

    private func columnX(_ column: Int, baseX: CGFloat) -> CGFloat {
        baseX + CGFloat(column) * colWidth + colWidth / 2
    }

    private func drawNutOrFretLines(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        let path = Path { p in
            if baseFret == 1 {
                let nutPath = CGMutablePath()
                nutPath.addRect(CGRect(x: baseX - 3, y: baseY - 2, width: 6, height: CGFloat(stringCount - 1) * stringSpacing + 4))
                p.addPath(Path(nutPath))
            }
            for col in 0...fretCount {
                let x = baseX + CGFloat(col) * colWidth
                p.move(to: CGPoint(x: x, y: baseY - 4))
                p.addLine(to: CGPoint(x: x, y: stringY(stringCount - 1, baseY: baseY) + 4))
            }
        }
        let lineWidth: CGFloat = baseFret == 1 ? 2.5 : 1.5
        context.stroke(path, with: .color(.primary.opacity(0.5)), lineWidth: lineWidth)
    }

    private func drawStringLines(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        for string in 0..<stringCount {
            let y = stringY(string, baseY: baseY)
            let path = Path { p in
                p.move(to: CGPoint(x: baseX, y: y))
                p.addLine(to: CGPoint(x: baseX + CGFloat(fretCount) * colWidth, y: y))
            }
            let width: CGFloat = string == 5 ? 1.8 : 1.2
            context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: width)
        }
    }

    private func drawFretNumber(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        let x = baseX + colWidth / 2
        let y = stringY(stringCount - 1, baseY: baseY) + 18
        context.draw(
            Text("\(baseFmt)fr")
                .font(.system(size: 10, weight: .medium)),
            at: CGPoint(x: x, y: y)
        )
    }

    private var baseFmt: Int { baseFret }

    private func drawStringMarkers(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        let x = baseX - 12
        for string in 0..<stringCount {
            let fretValue = frets.indices.contains(string) ? frets[string] : nil
            let y = stringY(string, baseY: baseY)

            if fretValue == nil {
                context.draw(
                    Text("X")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.red),
                    at: CGPoint(x: x, y: y)
                )
            } else if fretValue == 0 {
                context.draw(
                    Text("O")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary),
                    at: CGPoint(x: x, y: y)
                )
            }
        }
    }

    private func drawBarres(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        for barre in barres {
            let col = barre.fret - baseFret
            guard col >= 0, col < fretCount else { continue }
            let cx = columnX(col, baseX: baseX)
            let startY = stringY(barre.startString, baseY: baseY)
            let endY = stringY(barre.endString, baseY: baseY)

            let path = Path { p in
                p.move(to: CGPoint(x: cx - dotRadius - 2, y: startY))
                p.addQuadCurve(
                    to: CGPoint(x: cx + dotRadius + 2, y: startY),
                    control: CGPoint(x: cx, y: startY - dotRadius * 1.4)
                )
                p.move(to: CGPoint(x: cx - dotRadius - 2, y: endY))
                p.addQuadCurve(
                    to: CGPoint(x: cx + dotRadius + 2, y: endY),
                    control: CGPoint(x: cx, y: endY - dotRadius * 1.4)
                )
                p.move(to: CGPoint(x: cx - dotRadius - 2, y: startY))
                p.addLine(to: CGPoint(x: cx - dotRadius - 2, y: endY))
                p.move(to: CGPoint(x: cx + dotRadius + 2, y: startY))
                p.addLine(to: CGPoint(x: cx + dotRadius + 2, y: endY))
            }

            context.stroke(path, with: .color(.primary), lineWidth: 2.5)
        }
    }

    private func drawFingerDots(context: inout GraphicsContext, baseX: CGFloat, baseY: CGFloat, size: CGSize) {
        for string in 0..<stringCount {
            guard frets.indices.contains(string) else { continue }
            guard let fretValue = frets[string] else { continue }

            let isHighlighted = highlightString == string && highlightFret == fretValue

            let col = fretValue - baseFret
            if col < 0 || col >= fretCount {
                guard isHighlighted, col == -1 else { continue }
            }
            if fretValue == 0 && !isHighlighted { continue }

            let cx: CGFloat = col >= 0 ? columnX(col, baseX: baseX) : baseX
            let cy = stringY(string, baseY: baseY)

            let isRoot = rootString == string

            let dotColor: Color
            if isHighlighted {
                dotColor = .accentColor
            } else if isRoot {
                dotColor = .accentColor
            } else {
                dotColor = .primary
            }

            let rect = CGRect(
                x: cx - dotRadius,
                y: cy - dotRadius,
                width: noteDiameter,
                height: noteDiameter
            )

            context.fill(Path(ellipseIn: rect), with: .color(dotColor))

            if isRoot {
                context.stroke(Path(ellipseIn: rect), with: .color(.accentColor), lineWidth: 2)
            }

            if let finger = fingers.indices.contains(string) ? fingers[string] : nil {
                let text = Text("\(finger)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                context.draw(text, at: CGPoint(x: cx, y: cy))
            }
        }
    }
}
