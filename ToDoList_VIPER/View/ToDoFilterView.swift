//
//  ToDoFilterView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI


struct ToDoFilterView: View {
    @Binding var selectedFilter: ToDoFilter
    var allCount: Int
    var openCount: Int
    var closedCount: Int
    
    var body: some View {
        HStack {
            filterButton(title: "Все", count: allCount, filter: .all)
            filterDivider()
            filterButton(title: "Активные", count: openCount, filter: .open)
            filterButton(title: "Завершенные", count: closedCount, filter: .closed)
        }
        .padding(.horizontal)
    }
    
    private func filterButton(title: String, count: Int, filter: ToDoFilter) -> some View {
        Button(action: {
            withAnimation(.none) {
                selectedFilter = filter
            }
        }) {
            HStack {
                Text(title)
                filterCapsule(count: count, isSelected: selectedFilter == filter)
            }
            .styledAsFilterButton(isSelected: selectedFilter == filter)
        }
        .animation(.none, value: selectedFilter)
    }

    private func filterCapsule(count: Int, isSelected: Bool) -> some View {
        Capsule()
            .fill(isSelected ? FilterConstants.selectedColor : FilterConstants.deselectedColor)
            .frame(width: FilterConstants.capsuleWidth, height: FilterConstants.capsuleHeight)
            .overlay(
                Text("\(count)")
                    .font(.footnote)
                    .foregroundStyle(.indigo)
            )
    }

    private func filterDivider() -> some View {
        Divider()
            .frame(width: FilterConstants.dividerWidth, height: FilterConstants.dividerHeight)
            .background(Color.black)
            .padding(.horizontal, FilterConstants.dividerPadding)
    }
}

private extension View {
    func styledAsFilterButton(isSelected: Bool) -> some View {
        self
            .font(.subheadline)
            .fontWeight(isSelected ? .bold : .regular)
            .foregroundStyle(isSelected ? .indigo : .black)
            .padding(.vertical, 15)
            .padding(.horizontal, 5)
    }
}


private enum FilterConstants {
    static let verticalPadding: CGFloat = 15
    static let horizontalPadding: CGFloat = 5
    static let capsuleWidth: CGFloat = 25
    static let capsuleHeight: CGFloat = 20
    static let selectedColor = Color.white
    static let deselectedColor = Color.white.opacity(0.3)
    static let dividerWidth: CGFloat = 1
    static let dividerHeight: CGFloat = 20
    static let dividerPadding: CGFloat = 10
}
