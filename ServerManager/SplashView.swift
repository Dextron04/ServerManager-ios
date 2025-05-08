// SplashView.swift
import SwiftUI

struct SplashView: View {
    /// Controls whether the splash is visible
    @Binding var isPresented: Bool
    
    // Animation state - reduced number of animated elements to prevent performance issues
    @State private var iconScale: CGFloat = 0.2
    @State private var iconRotation: Double = -30
    @State private var iconOpacity: Double = 0
    @State private var iconGlow: Bool = false
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 10
    @State private var taglineOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var progressValue: CGFloat = 0
    
    // Configurable properties
    let accentColor: Color = .blue
    let secondaryAccentColor: Color = .cyan
    let animationDuration: Double = 2.5
    
    var body: some View {
        ZStack {
            // Simple background
            Color(.systemBackground)
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .overlay(
                    // Simple gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(0.05),
                            secondaryAccentColor.opacity(0.07)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
            
            // Main content
            VStack(spacing: 20) {
                // Logo with simple effects
                Image(systemName: "server.rack")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
                    .opacity(iconOpacity)
                    .shadow(color: accentColor.opacity(iconGlow ? 0.7 : 0),
                            radius: iconGlow ? 15 : 0)
                    .frame(height: 80)
                
                // App name with reveal effect
                Text("Dex Web")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                
                // Tagline with animation
                Text("Monitor Servers Like a Pro")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .opacity(taglineOpacity)
                    .padding(.top, -5)
                
                // Progress bar
                progressBar
                    .opacity(taglineOpacity)
                    .padding(.top, 10)
            }
            .padding()
        }
        .onAppear {
            reset()
            runAnimation()
        }
    }
    
    // MARK: - UI Components
    
    private var progressBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 160, height: 4)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 160 * progressValue, height: 4)
        }
    }
    
    // MARK: - Animation Methods
    
    private func reset() {
        iconScale = 0.2
        iconRotation = -30
        iconOpacity = 0
        iconGlow = false
        textOpacity = 0
        textOffset = 10
        taglineOpacity = 0
        backgroundOpacity = 0
        progressValue = 0
    }
    
    private func runAnimation() {
        // Use Task instead of multiple DispatchQueue calls to reduce overhead
        Task { @MainActor in
            // Background fade in
            withAnimation(.easeIn(duration: 0.5)) {
                backgroundOpacity = 1.0
            }
            
            // Icon animation with small delay
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
                iconRotation = 0
                iconOpacity = 1.0
            }
            
            // Icon glow after icon appears
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            withAnimation(.easeInOut(duration: 0.5)) {
                iconGlow = true
            }
            
            // Text animation
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                textOpacity = 1.0
                textOffset = 0
            }
            
            // Tagline animation
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            withAnimation(.easeOut(duration: 0.5)) {
                taglineOpacity = 1.0
            }
            
            // Progress bar animation
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            withAnimation(.easeInOut(duration: 0.8)) {
                progressValue = 1.0
            }
            
            // Final exit animation
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            withAnimation(.easeIn(duration: 0.6)) {
                isPresented = false
            }
        }
    }
}
