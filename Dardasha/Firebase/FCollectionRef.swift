//
//  FCollectionRef.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import Firebase

enum FCollectionReference : String {
    case User
    case Chat
    case Message
    case Typing
    case Channel
}

func FirestoreReference(_ collectionRef : FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionRef.rawValue)
}
