//
//  MenuView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var presenter: ToDoPresenter

    var body: some View {
        Menu {
            sortButton(label: "В начало", systemImage: "arrow.up", sortOrder: .newestFirst)
            sortButton(label: "В конец", systemImage: "arrow.down", sortOrder: .oldestFirst)
            sortButton(label: "По названию (А–Я)", systemImage: "textformat", sortOrder: .alphabeticalAZ)
            sortButton(label: "По названию (Я–А)", systemImage: "textformat", sortOrder: .alphabeticalZA)
        } label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .styledAsMenuIcon()
        }
    }

    private func sortButton(label: String, systemImage: String, sortOrder: ToDoSortOrder) -> some View {
        Button(action: {
            presenter.changeSortOrder(to: sortOrder)
        }) {
            Label(label, systemImage: systemImage)
        }
    }
}

private enum MenuConstants {
    static let menuIconFont: Font = .title2
    static let menuIconColor: Color = .blue
    static let menuIconPadding: CGFloat = 10
}

extension View {
    func styledAsMenuIcon() -> some View {
        self
            .font(MenuConstants.menuIconFont)
            .foregroundStyle(MenuConstants.menuIconColor)
            .padding(MenuConstants.menuIconPadding)
    }
}
