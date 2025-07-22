import SwiftUI

struct HabitCard: View {
    let icon: String
    let name: String
    @State var current: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        return Double(current) / Double(goal)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(icon)
                    .font(.title3)
                
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("0%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(current)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("/\(goal)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    if current > 0 {
                        current -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    if current < goal {
                        current += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}
