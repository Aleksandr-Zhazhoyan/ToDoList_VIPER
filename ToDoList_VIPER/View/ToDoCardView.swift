//
//  ToDoCardView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI

struct ToDoCardView: View {
    var task: ToDoEntity
    var presenter: ToDoPresenter
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .styledAsTaskTitle(completed: task.isCompleted)
                        .onTapGesture {
                            isExpanded.toggle()
                        }
                    Text(task.details)
                        .styledAsTaskDetails()
                }
                Spacer()
                Button(action: {
                    presenter.toggleTaskCompletion(task: task)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .styledAsCompletionButton(completed: task.isCompleted)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Divider()
            HStack {
                Text("Сегодня")
                    .font(.footnote)
                    .foregroundStyle(.purple)
                
                HStack {
                    Text("\(task.startTime ?? Date(), formatter: timeFormatter) - \(task.endTime.map { timeFormatter.string(from: $0) } ?? "Н/Д")")
                        .font(.footnote)
                        .foregroundStyle(.purple)
                }
            }
            .padding(.vertical, 5)
        }
        .styledAsTaskCard()
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale.autoupdatingCurrent
    return formatter
}()


extension View {
    func styledAsTaskCard() -> some View {
        self
            .padding(ToDoCardConstants.cardPadding)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: ToDoCardConstants.cardCornerRadius))
            .shadow(color: Color.black.opacity(0.1), radius: ToDoCardConstants.cardShadowRadius, x: 0, y: 5)
    }
    
    func styledAsTaskTitle(completed: Bool) -> some View {
        self
            .strikethrough(completed)
            .foregroundStyle(completed ? .myAccen : .myAccen)
            .font(ToDoCardConstants.taskTitleFont)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    func styledAsTaskDetails() -> some View {
        self
            .font(ToDoCardConstants.taskDetailsFont)
            .foregroundStyle(.black)
            .frame(height: 20)
    }
    
    func styledAsCompletionButton(completed: Bool) -> some View {
        self
            .foregroundStyle(completed ? .green : .indigo)
            .font(.system(size: ToDoCardConstants.completionButtonSize))
    }
}

private enum ToDoCardConstants {
    static let cardPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 12
    static let cardShadowRadius: CGFloat = 5
    static let taskTitleFont: Font = .headline
    static let taskDetailsFont: Font = .subheadline
    static let completionButtonSize: CGFloat = 24
}
