//
//  AuthState.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 29/6/25.
//

import FirebaseAuth

enum AuthState: Equatable {
    case loading
    case signedIn(User)
    case signedOut
}
