//
//  TrashItemView.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import SwiftUI

struct TrashItemView: View {
    let imageNamed: String
    
    var body: some View {
        Image(imageNamed)
    }
}

#Preview {
    TrashItemView(imageNamed: "angry_trash")
}
