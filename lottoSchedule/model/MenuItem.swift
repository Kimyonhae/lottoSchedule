//
//  MenuItem.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/3/25.
//

// PopOver 메뉴 모델링
struct MenuItem {
    let title: String
    let iconName: String
    let action: action
    enum action {
        case update // 수정
        case delete // 삭제
        case destination // 이동
    }
}
