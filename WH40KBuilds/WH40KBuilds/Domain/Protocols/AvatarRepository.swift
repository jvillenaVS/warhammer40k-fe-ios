//
//  AvatarRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import Combine
import UIKit

public protocol AvatarRepository {
    func fetchAvatar(for uid: String) async throws -> URL?
    func uploadAvatar(_ image: UIImage, for uid: String) async throws -> URL
    func deleteAvatar(for uid: String) async throws
}
