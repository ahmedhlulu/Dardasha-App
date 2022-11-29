//
//  MKSender.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import MessageKit
import UIKit

struct MKSender: SenderType, Equatable {
    
    var senderId: String
    var displayName: String
}
