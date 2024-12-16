//
//  ContentView.swift
//  OTPSample
//
//  Created by Akira Matsuda on 2024/12/14.
//

import SwiftUI

struct ContentView: View {
    @State var code: String = ""

    var body: some View {
        VStack {
            OTPTextField(numberOfDigitsOfCode: 5, code: $code)
            Button("Fill") {
                code = "12345"
            }
            Button("Clear") {
                code = ""
            }
        }
    }
}

#Preview {
    ContentView()
}
