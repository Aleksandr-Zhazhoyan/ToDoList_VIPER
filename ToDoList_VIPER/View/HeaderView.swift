//
//  HeaderView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI

struct HeaderView: View {
    let formattedDate: String
    @Binding var showNewTaskForm: Bool
    @Binding var editingTask: ToDoEntity?
    @ObservedObject var presenter: ToDoPresenter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: HeaderViewConstants.vStackSpacing) {
                Text("Задачи на сегодня")
                    .font(HeaderViewConstants.titleFont)
                    .fontWeight(.bold)
                Text(formattedDate)
                    .font(HeaderViewConstants.subtitleFont)
                    .foregroundStyle(.purple)
            }
            Spacer()
            Button(action: {
                editingTask = nil
                showNewTaskForm.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.purple)
                    Text("Новая задача")
                        .foregroundStyle(.purple)
                }
                .styledAsPrimaryButton()
            }
            .sheet(isPresented: $showNewTaskForm) {
                NewToDoView(isPresented: $showNewTaskForm, presenter: presenter, taskToEdit: $editingTask)
            }
        }
        .padding(.horizontal, HeaderViewConstants.horizontalPadding)
    }
}

// Константы для параметров верстки в HeaderView
private enum HeaderViewConstants {
    static let vStackSpacing: CGFloat = 4
    static let titleFont: Font = .title
    static let subtitleFont: Font = .subheadline
    static let horizontalPadding: CGFloat = 16
}

extension View {
    func styledAsPrimaryButton() -> some View {
        self
            .bold()
            .padding(.vertical, ButtonConstants.verticalPadding)
            .padding(.horizontal, ButtonConstants.horizontalPadding)
            .background(Color.blue.opacity(ButtonConstants.backgroundOpacity))
            .foregroundColor(.blue)
            .clipShape(RoundedRectangle(cornerRadius: ButtonConstants.cornerRadius))
    }
}

// Константы для параметров стилизации кнопок
private enum ButtonConstants {
    static let verticalPadding: CGFloat = 10
    static let horizontalPadding: CGFloat = 15
    static let backgroundOpacity: Double = 0.1
    static let cornerRadius: CGFloat = 15
}
