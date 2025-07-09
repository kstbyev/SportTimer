//
//  UserProfile.swift
//  SportTime
//
//  Created by Madi Sharipov on 09.07.2025.
//

import Foundation
import SwiftUI

@MainActor
class UserProfile: ObservableObject {
    @Published var avatarImage: UIImage?
    @Published var userName: String = "Спортсмен"
    @Published var userStatus: String = "Активный пользователь"
    
    private let avatarKey = "userAvatar"
    private let nameKey = "userName"
    private let statusKey = "userStatus"
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        // Загружаем имя пользователя
        if let savedName = UserDefaults.standard.string(forKey: nameKey) {
            userName = savedName
        }
        
        // Загружаем статус пользователя
        if let savedStatus = UserDefaults.standard.string(forKey: statusKey) {
            userStatus = savedStatus
        }
        
        // Загружаем аватар
        if let imageData = UserDefaults.standard.data(forKey: avatarKey),
           let image = UIImage(data: imageData) {
            avatarImage = image
        }
    }
    
    func saveUserData() {
        UserDefaults.standard.set(userName, forKey: nameKey)
        UserDefaults.standard.set(userStatus, forKey: statusKey)
        
        if let avatarImage = avatarImage,
           let imageData = avatarImage.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: avatarKey)
        }
    }
    
    func updateAvatar(_ image: UIImage) {
        avatarImage = image
        saveUserData()
    }
    
    func updateUserName(_ name: String) {
        userName = name
        saveUserData()
    }
    
    func updateUserStatus(_ status: String) {
        userStatus = status
        saveUserData()
    }
    
    func clearAvatar() {
        avatarImage = nil
        UserDefaults.standard.removeObject(forKey: avatarKey)
    }
} 