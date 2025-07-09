//
//  StorageReference+Extensions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import FirebaseStorage
import SwiftUI

extension StorageReference {
    func putDataAsync(_ data: Data,
                      metadata: StorageMetadata?) async throws {
        try await withCheckedThrowingContinuation { cont in
            putData(data, metadata: metadata) { _, err in
                err == nil ? cont.resume() : cont.resume(throwing: err!)
            }
        }
    }
}
