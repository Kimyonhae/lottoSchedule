//
//  LottoCheckNotification.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/3/25.
//

import Foundation
import UserNotifications
import UIKit

final class LottoCheckNotification {
    static let shared = LottoCheckNotification()
    let identifier = "weekly_check_lotto"
    private init() {}
    
    // TODO: 권한이 없을 경우 권한 설정 페이지 이동
    func checkNoticePermission() {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            if setting.authorizationStatus != .authorized { // 권한 요청
                #if DEBUG
                    print("여기가 권한이 없을 경우 와야 함")
                #endif
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "알림 권한이 필요합니다",
                        message: "로또 당첨 여부를 알림으로 받기 위해 알림 권한을 허용해주세요",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
                        self.removeScheduledNotifications() // Notification 삭제
                    })
                    alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    
                    if let mainVC = UIApplication.shared.connectedScenes
                        .compactMap({( $0 as? UIWindowScene)?.keyWindow })
                        .first?.rootViewController {
                        mainVC.present(alert, animated: true)
                    }
                }
            } else { // 권한이 있는 경우
                self.removeScheduledNotifications()
                self.scheduleWeeklyNotification() // 등록 해주기
            }
        }
    }
    
    func scheduleWeeklyNotification() {
        let notice = UNMutableNotificationContent()
        notice.title = "로또 결과 확인 시간입니다!"
        notice.body = "이번 주 당첨 결과를 확인해세요~"
        notice.sound = .default
        notice.badge = nil
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 8
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: notice,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
                if let error = error {
                    print("알림 등록 실패 : \(error)")
                }else {
                    print("알림 등록 성공~")
                }
            #endif
        }
    }
    // 등록된 알림 제거
    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // 현재 예약된 알림 조회 (디버깅용)
    func printAllScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            #if DEBUG
                print("등록된 알림:")
                for r in requests {
                    print(" - \(r.identifier)")
                }
            #endif
        }
    }
    
    // Notification Test Case
    func addNotificationTestCase() {
        let content = UNMutableNotificationContent()
        content.title = "test 제목"
        content.body = "test를 위한 내용이에유"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let req = UNNotificationRequest(identifier: "TEST", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(req)
    }
}
