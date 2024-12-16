//
//  OTPTextField.swift
//  OTPSample
//
//  Created by Akira Matsuda on 2024/12/14.
//

import Combine
import SwiftUI

// MARK: - OTPTextField

struct OTPTextField: View {
    // MARK: Lifecycle

    init(numberOfDigitsOfCode: Int, code: Binding<String>) {
        self.numberOfDigitsOfCode = numberOfDigitsOfCode
        _code = code
        _pins = State(initialValue: Array(repeating: "", count: numberOfDigitsOfCode))
    }

    // MARK: Internal

    enum FocusPin: Hashable {
        case pin(Int)

        // MARK: Internal

        func previous() -> FocusPin? {
            if case let .pin(index) = self {
                return .pin(max(index - 1, 0))
            }
            return nil
        }

        func next(max: Int) -> FocusPin? {
            if case let .pin(index) = self {
                return .pin(min(index + 1, max))
            }
            return nil
        }
    }

    var numberOfDigitsOfCode: Int

    var body: some View {
        HStack {
            ForEach(0 ..< numberOfDigitsOfCode, id: \.self) { index in
                TextField("", text: $pins[index])
                    .modifier(OTPTextFieldModifier(pin: $pins[index]))
                    .textContentType(.oneTimeCode)
                    .allowsHitTesting(currendNumberOfDigits() == index && pins[index].isEmpty)
                    .focused($focuesedPin, equals: .pin(index))
                    .onChange(of: pins[index]) { _, newValue in
                        if code.count >= numberOfDigitsOfCode {
                            focuesedPin = nil
                        }
                        else if newValue.count == 1 {
                            focuesedPin = focuesedPin?.next(max: numberOfDigitsOfCode)
                            updateCodeFromPins()
                        }
                        else if newValue.count > numberOfDigitsOfCode {
                            code = newValue
                            updatePinsFromCode()
                            focuesedPin = nil
                        }
                    }.onKeyPress { press in
                        if press.key == .delete {
                            if pins[index].isEmpty {
                                focuesedPin = focuesedPin?.previous()
                                pins[max(0, index - 1)] = ""
                            }
                        }
                        if Int(press.characters) == nil {
                            return .handled
                        }
                        updateCodeFromPins()
                        return .ignored
                    }
            }
        }.onChange(of: code) { _, _ in
            updatePinsFromCode()
        }.onAppear {
            updatePinsFromCode()
        }
    }

    // MARK: Private

    @FocusState private var focuesedPin: FocusPin?
    @Binding private var code: String
    @State private var pins: [String]

    private func updateCodeFromPins() {
        code = pins.joined()
    }

    private func currendNumberOfDigits() -> Int {
        return Array(code.prefix(numberOfDigitsOfCode)).count
    }

    private func updatePinsFromCode() {
        let codeArray = Array(code.prefix(numberOfDigitsOfCode))
        for (index, char) in codeArray.enumerated() {
            pins[index] = String(char)
        }

        for index in codeArray.count ..< numberOfDigitsOfCode {
            pins[index] = ""
        }
    }
}

// MARK: - OTPTextFieldModifier

struct OTPTextFieldModifier: ViewModifier {
    @Binding var pin: String

    var textLimit = 1

    func limitText(_ upper: Int) {
        if pin.count > upper {
            pin = String(pin.prefix(upper))
        }
    }

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(pin)) { _ in limitText(textLimit) }
            .frame(width: 40, height: 48)
            .font(.system(size: 14))
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

#Preview {
    OTPTextField(numberOfDigitsOfCode: 5, code: .constant("12345"))
}
