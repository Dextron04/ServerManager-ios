// SplashView.swift
import SwiftUI

struct SplashView: View {
  /// Controls whether the splash is visible
  @Binding var isPresented: Bool

  // Animation state
  @State private var iconScale: CGFloat = 0.2
  @State private var iconRotation: Double = -30
  @State private var iconOpacity: Double = 0
  @State private var iconGlow: Bool = false
  @State private var textOpacity: Double = 0
  @State private var textOffset: CGFloat = 10
  @State private var taglineOpacity: Double = 0
  @State private var backgroundOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.primary.opacity(0.05)
        .edgesIgnoringSafeArea(.all)
        .opacity(backgroundOpacity)

      VStack(spacing: 20) {
        Image(systemName: "server.rack.fill")
          .font(.system(size: 40))
          .foregroundColor(.accentColor)
          .scaleEffect(iconScale)
          .rotationEffect(.degrees(iconRotation))
          .opacity(iconOpacity)
          .shadow(color: .accentColor.opacity(0.5),
                  radius: iconGlow ? 10 : 0)

        Text("Dex Web")
          .font(.largeTitle.bold())
          .opacity(textOpacity)
          .offset(y: textOffset)

        Text("Monitor Servers Like a Pro")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .opacity(taglineOpacity)
      }
      .padding()
    }
    .onAppear {
      reset()
      runAnimation()
    }
  }

  // MARK: - Helpers

  private func reset() {
    iconScale = 0.2; iconRotation = -30; iconOpacity = 0
    iconGlow = false; textOpacity = 0; textOffset = 10
    taglineOpacity = 0; backgroundOpacity = 0
  }

  private func runAnimation() {
    withAnimation(.easeIn(duration: 0.3)) {
      backgroundOpacity = 1.0
    }

    withAnimation(
      .spring(response: 0.6, dampingFraction: 0.6)
        .delay(0.2)
    ) {
      iconScale = 1.0; iconRotation = 0; iconOpacity = 1.0
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      withAnimation(.easeInOut(duration: 0.4)) {
        iconGlow = true
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      withAnimation(.easeOut(duration: 0.5)) {
        textOpacity = 1.0; textOffset = 0
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
      withAnimation(.easeOut(duration: 0.5)) {
        taglineOpacity = 1.0
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
      withAnimation(.easeIn(duration: 0.6)) {
        isPresented = false
      }
    }
  }
}
