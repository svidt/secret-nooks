//
//  NameSnowView.swift
//  SecretSanta
//
//  Created by Kristian Emil on 02/12/2024.
//

import SwiftUI

struct NameSnowParticle: Identifiable {
    let id = UUID()
    let name: String
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var rotation: Double
    var wobble: CGFloat
    var wobbleSpeed: CGFloat
    var opacity: CGFloat
}

class NameSnowViewModel: ObservableObject {
    @Published var particles: [NameSnowParticle] = []
    private let windStrength: CGFloat = 0.0003
    private var windOffset: CGFloat = 0
    
    func updateParticles(with names: [String]) {
        particles = names.map { name in
            createParticle(name: name, atTop: Bool.random())
        }
    }
    
    private func createParticle(name: String, atTop: Bool = true) -> NameSnowParticle {
        NameSnowParticle(
            name: name,
            x: CGFloat.random(in: -0.2...1.2),
            y: atTop ? CGFloat.random(in: -0.2...0) : CGFloat.random(in: 0...1),
            speed: CGFloat.random(in: 0.001...0.003),
            rotation: Double.random(in: -45...45),
            wobble: CGFloat.random(in: -1...1),
            wobbleSpeed: CGFloat.random(in: 0.001...0.002),
            opacity: CGFloat.random(in: 0.5...0.8)
        )
    }
    
    func updatePositions() {
        // Update wind
        windOffset += CGFloat.random(in: -0.1...0.1) * windStrength
        windOffset = max(min(windOffset, 0.001), -0.001)
        
        particles = particles.map { particle in
            var newParticle = particle
            
            // Update position
            newParticle.y += particle.speed
            
            // Apply wind and wobble
            newParticle.x += windOffset
            newParticle.x += sin(newParticle.y * 10) * particle.wobble * particle.wobbleSpeed
            
            // Update rotation slightly
            newParticle.rotation += Double.random(in: -0.5...0.5)
            
            // Reset particle if it goes off screen
            if newParticle.y > 1.2 || newParticle.x < -0.2 || newParticle.x > 1.2 {
                newParticle = createParticle(name: particle.name)
            }
            
            return newParticle
        }
    }
}

struct NameSnowView: View {
    @ObservedObject var viewModel: NameSnowViewModel
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in viewModel.particles {
                    context.opacity = particle.opacity
                    context.translateBy(x: particle.x * size.width, y: particle.y * size.height)
                    context.rotate(by: .degrees(particle.rotation))
                    
                    // Create text using resolved font
                    let text = Text(particle.name)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    context.draw(text, at: .zero)
                    
                    // Reset transformations for next particle
                    context.transform = .identity
                }
            }
        }
        .onReceive(timer) { _ in
            viewModel.updatePositions()
        }
    }
}
