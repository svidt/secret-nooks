//
//  SnowfallView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct SnowParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var wobble: CGFloat  // For side-to-side movement
    var wobbleSpeed: CGFloat  // How fast it wobbles
    var opacity: CGFloat  // Individual opacity
}

class SnowfallViewModel: ObservableObject {
    @Published var particles: [SnowParticle] = []
    private let particleCount = 100  // Increased for better effect
    private let windStrength: CGFloat = 0.0005  // Base wind effect
    private var windOffset: CGFloat = 0  // Current wind value
    
    init() {
        resetParticles()
    }
    
    func resetParticles() {
        particles = (0..<particleCount).map { _ in
            createParticle(atTop: Bool.random())
        }
    }
    
    private func createParticle(atTop: Bool = true) -> SnowParticle {
        SnowParticle(
            x: CGFloat.random(in: -0.2...1.2),  // Allow particles to enter from sides
            y: atTop ? CGFloat.random(in: -0.2...0) : CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...8),
            speed: CGFloat.random(in: 0.001...0.004),
            wobble: CGFloat.random(in: -1...1),
            wobbleSpeed: CGFloat.random(in: 0.001...0.003),
            opacity: CGFloat.random(in: 0.5...0.9)
        )
    }
    
    func updateParticles() {
        // Update wind
        windOffset += CGFloat.random(in: -0.1...0.1) * windStrength
        windOffset = max(min(windOffset, 0.001), -0.001)  // Limit wind strength
        
        particles = particles.map { particle in
            var newParticle = particle
            
            // Update position
            newParticle.y += particle.speed
            
            // Apply wind and wobble
            newParticle.x += windOffset
            newParticle.x += sin(newParticle.y * 10) * particle.wobble * particle.wobbleSpeed
            
            // Reset particle if it goes off screen
            if newParticle.y > 1.2 || newParticle.x < -0.2 || newParticle.x > 1.2 {
                newParticle = createParticle()
            }
            
            return newParticle
        }
    }
}

struct SnowfallView: View {
    @StateObject private var viewModel = SnowfallViewModel()
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()  // 60 FPS
    
    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geometry in
                Canvas { context, size in
                    for particle in viewModel.particles {
                        let x = particle.x * size.width
                        let y = particle.y * size.height
                        
                        context.opacity = particle.opacity
                        context.fill(
                            Circle().path(in: CGRect(
                                x: x - particle.size/2,
                                y: y - particle.size/2,
                                width: particle.size,
                                height: particle.size
                            )),
                            with: .color(.white)
                        )
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            viewModel.updateParticles()
        }
    }
}

#Preview {
    ZStack {
        Color.black  // Dark background to see snow better
        SnowfallView()
    }
}

//import SwiftUI
//
//struct SnowParticle: Identifiable {
//    let id = UUID()
//    var x: CGFloat
//    var y: CGFloat
//    var size: CGFloat
//    var speed: CGFloat
//}
//
//class SnowfallViewModel: ObservableObject {
//    @Published var particles: [SnowParticle] = []
//    private let particleCount = 50
//    
//    init() {
//        resetParticles()
//    }
//    
//    func resetParticles() {
//        particles = (0..<particleCount).map { _ in
//            SnowParticle(
//                x: CGFloat.random(in: 0...1),
//                y: CGFloat.random(in: 0...1),
//                size: CGFloat.random(in: 2...6),
//                speed: CGFloat.random(in: 0.001...0.003)
//            )
//        }
//    }
//    
//    func updateParticles() {
//        particles = particles.map { particle in
//            var newParticle = particle
//            newParticle.y += particle.speed
//            
//            if newParticle.y > 1 {
//                newParticle.y = 0
//                newParticle.x = CGFloat.random(in: 0...1)
//            }
//            
//            return newParticle
//        }
//    }
//}
//
//struct SnowfallView: View {
//    @StateObject private var viewModel = SnowfallViewModel()
//    let timer = Timer.publish(every: 0.042, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                ForEach(viewModel.particles) { particle in
//                    Circle()
//                        .fill(.white)
//                        .frame(width: particle.size, height: particle.size)
//                        .position(
//                            x: particle.x * geometry.size.width,
//                            y: particle.y * geometry.size.height
//                        )
//                        .opacity(0.7)
//                }
//            }
//        }
//        .onReceive(timer) { _ in
//            viewModel.updateParticles()
//        }
//    }
//}
//
//#Preview {
//    SnowfallView()
//}
