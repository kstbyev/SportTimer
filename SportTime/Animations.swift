//
//  Animations.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import SwiftUI

// MARK: - Custom Animations
struct Animations {
    
    // MARK: - Loading Animation
    static let loading = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    
    // MARK: - Transition Animations
    static let slideTransition = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let fadeTransition = AnyTransition.opacity.combined(with: .scale)
    
    // MARK: - Button Animations
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let buttonRelease = Animation.spring(response: 0.4, dampingFraction: 0.8)
    
    // MARK: - Progress Animations
    static let progressAnimation = Animation.easeInOut(duration: 1.0)
    
    // MARK: - Card Animations
    static let cardAppear = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let cardDisappear = Animation.easeInOut(duration: 0.3)
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: AppConstants.standardPadding) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(AppColors.primary, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animations.loading, value: isAnimating)
            
            Text("Сохранение...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Animated Button Style
struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(configuration.isPressed ? Animations.buttonPress : Animations.buttonRelease, value: configuration.isPressed)
    }
}

// MARK: - Animated Card View
struct AnimatedCardView<Content: View>: View {
    let content: Content
    @State private var isVisible = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .animation(Animations.cardAppear.delay(0.1), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

// MARK: - Pulse Animation
struct PulseAnimation: View {
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(AppColors.primary.opacity(0.3))
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.0 : 1.0)
            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ]),
            startPoint: UnitPoint(x: phase, y: 0),
            endPoint: UnitPoint(x: phase + 0.5, y: 0)
        )
        .mask(Rectangle())
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
} 