//
//  ContentView.swift
//  Calculator
//
//  Created by Minhui Zhao on 2020/10/26.
//  Copyright © 2020 Minhui Zhao. All rights reserved.
//

import SwiftUI

struct Theme {
  struct Grid {
    // screenWidth = buttonWidth * 5
    // buttonWidth = spacing * 5
    static let spacing = UIScreen.main.bounds.size.width / 25
    
    static let width: CGFloat = UIScreen.main.bounds.size.width / 5
    static let height: CGFloat = UIScreen.main.bounds.size.width / 5 * 0.8
  }
  
  struct Color {
    static let lightButtonBackground = SwiftUI.Color(#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1))
    static let lightButtonSelectedBackground = SwiftUI.Color(#colorLiteral(red: 0.9294117647, green: 0.9254901961, blue: 0.9137254902, alpha: 1))
    static let lightButtonText = SwiftUI.Color(#colorLiteral(red: 0.3529411765, green: 0.337254902, blue: 0.3254901961, alpha: 1))
    static let darkButtonBackground = SwiftUI.Color(#colorLiteral(red: 0.4549019608, green: 0.4509803922, blue: 0.4509803922, alpha: 1))
    static let darkButtonSelectedBackground = SwiftUI.Color(#colorLiteral(red: 0.3803921569, green: 0.3803921569, blue: 0.3803921569, alpha: 1))
    static let darkButtonText = SwiftUI.Color(#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1))
    static let appBackground = SwiftUI.Color(#colorLiteral(red: 0.8823529412, green: 0.8784313725, blue: 0.8745098039, alpha: 1))
    static let screenBackground = SwiftUI.Color(#colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.7607843137, alpha: 1))
    static let screenBorder = SwiftUI.Color(#colorLiteral(red: 0.3882352941, green: 0.3764705882, blue: 0.3647058824, alpha: 1))
  }
}

enum CalculatorKey {
  enum Number: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case point = "."
  }
  
  enum SingleOperator: String {
    case allClear = "AC"
    case reverseSign = "+/-"
    case percentage = "%"
  }
  
  enum DoubleOperator: String {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
    case equal = "="
  }
}

struct ContentView: View {
  @State private var leftValue: Double = 0
  @State private var rightValue: Double? = nil
  @State private var op: CalculatorKey.DoubleOperator? = nil
  @State private var hasPointSuffix = false

  private var displayValue: String {
    let formattedValue = format(value: rightValue ?? leftValue) ?? "0"
    return hasPointSuffix ? "\(formattedValue)." : formattedValue
  }
  
  private var width: CGFloat {
    UIScreen.main.bounds.size.width
  }
  private var height: CGFloat {
    UIScreen.main.bounds.size.height
  }

  private func format(value: Double) -> String? {
    let formatter = NumberFormatter()
    let number = NSNumber(value: value)
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 16
    return formatter.string(from: number)
  }
  
  func handleNumberInput(key: CalculatorKey.Number) {
    if case .equal = op {
      leftValue = Double(key.rawValue) ?? 0
      op = nil

      guard case .point = key else {
        return
      }
    }

    if case .point = key {
      hasPointSuffix = !displayValue.contains(".")
      return
    }

    if op == nil {
      leftValue = Double("\(displayValue)\(key.rawValue)")!
    } else {
      rightValue = rightValue == nil
        ? Double(key.rawValue)
        : Double("\(displayValue)\(key.rawValue)")!
    }
    hasPointSuffix = false
  }
  
  func handleSingleOperator(key: CalculatorKey.SingleOperator) {
    op = nil
    rightValue = nil
    switch key {
      case .allClear:
        leftValue = 0
      case .reverseSign:
        leftValue *= -1
      case .percentage:
        leftValue *= 0.01
    }
  }
  
  func handleDoubleOperator(key: CalculatorKey.DoubleOperator) {
    guard let right = rightValue, op != nil else {
      op = key
      return
    }

    switch op {
      case .add:
        leftValue += right
      case .subtract:
        leftValue -= right
      case .multiply:
        leftValue *= right
      case .divide:
        leftValue /= right
      default:
        break
    }
    op = key
    rightValue = nil
  }
  
  var body: some View {
    VStack (spacing: Theme.Grid.spacing * 2) {
      Spacer()
      NumberScreen(value: displayValue)
      HStack (spacing: Theme.Grid.spacing) {
        VStack (spacing: Theme.Grid.spacing) {
          SingleOperatorArea(onInput: handleSingleOperator)
          NumberArea(onInput: handleNumberInput)
        }
        DoubleOperatorArea(onInput: handleDoubleOperator)
      }
      Spacer()
    }
    .padding(Theme.Grid.spacing)
    .background(Theme.Color.appBackground)
  }
}

struct NumberScreen: View {
  var value: String
  
  private var width: CGFloat {
    Theme.Grid.width * 4 + Theme.Grid.spacing * 3
  }
  private var height: CGFloat {
    Theme.Grid.height * 2 + Theme.Grid.spacing * 1
  }
  
  var body: some View {
    Text(value)
      .frame(width: width, height: height, alignment: .bottomTrailing)
      .font(.system(size: 42, weight: .bold, design: .monospaced))
      .foregroundColor(.black)
      .background(Theme.Color.screenBackground)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Theme.Color.screenBorder, lineWidth: 5)
      )
  }
}

struct DoubleOperatorArea: View {
  private let operators: [CalculatorKey.DoubleOperator] = [
    .divide, .multiply, .subtract, .add, .equal
  ]

  var onInput: (CalculatorKey.DoubleOperator) -> Void
  
  var body: some View {
    VStack (spacing: Theme.Grid.spacing) {
      ForEach(operators, id: \.self) { op in
        KeyButton(
          label: op.rawValue,
          style: KeyButtonStyle(
            background: Theme.Color.darkButtonBackground,
            selectedBackground: Theme.Color.darkButtonSelectedBackground
          ),
          action: {
            self.onInput(op)
          }
        )
      }
    }
  }
}

struct SingleOperatorArea: View {
  private let operators: [CalculatorKey.SingleOperator] = [
    .allClear, .reverseSign, .percentage
  ]
  
  var onInput: (CalculatorKey.SingleOperator) -> Void
  
  var body: some View {
    HStack (spacing: Theme.Grid.spacing) {
      ForEach(operators, id: \.self) { op in
        KeyButton(
          label: op.rawValue,
          style: KeyButtonStyle(
            background: Theme.Color.darkButtonBackground,
            selectedBackground: Theme.Color.darkButtonSelectedBackground
          ),
          action: {
            self.onInput(op)
          }
        )
      }
    }
  }
}

struct NumberArea: View {
  private let numbers: [[CalculatorKey.Number]] = [
    [.seven, .eight, .nine],
    [.four, .five, .six],
    [.one, .two, .three],
  ]
  
  var onInput: (CalculatorKey.Number) -> Void
  
  var buttonStyle = KeyButtonStyle(
    background: Theme.Color.lightButtonBackground,
    selectedBackground: Theme.Color.lightButtonSelectedBackground,
    color: Theme.Color.lightButtonText
  )
  
  var body: some View {
    VStack (spacing: Theme.Grid.spacing) {
      ForEach(numbers, id: \.self) { rowNumbers in
        HStack(spacing: Theme.Grid.spacing) {
          ForEach(rowNumbers, id: \.self) { number in
            KeyButton(
              label: number.rawValue,
              style: self.buttonStyle,
              action: {
                self.onInput(number)
              }
            )
          }
        }
      }
      HStack (spacing: Theme.Grid.spacing) {
        KeyButton(
          label: CalculatorKey.Number.zero.rawValue,
          style: KeyButtonStyle(
            colSpan: 2,
            background: buttonStyle.background,
            selectedBackground: buttonStyle.selectedBackground,
            color: buttonStyle.color
          ),
          action: {
            self.onInput(.zero)
          }
        )
        KeyButton(
          label: CalculatorKey.Number.point.rawValue,
          style: buttonStyle,
          action: {
            self.onInput(.point)
          }
        )
      }
    }
  }
}

struct KeyButtonStyle: ButtonStyle {
  var rowSpan: Int = 1
  var colSpan: Int = 1
  var background: Color = Color.gray
  var selectedBackground: Color = Color.gray
  var color: Color = Color.white
  
  private var width: CGFloat {
    let span = CGFloat(colSpan)
    return Theme.Grid.width * span + Theme.Grid.spacing * (span - 1)
  }
  private var height: CGFloat {
    let span = CGFloat(rowSpan)
    return Theme.Grid.height * span + Theme.Grid.spacing * (span - 1)
  }
  private var radius: CGFloat {
    min(width, height) * 0.15
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(
        width: width,
        height: height,
        alignment: .center
    )
      .font(.system(size: 32, weight: .semibold, design: .monospaced))
      .foregroundColor(color)
      .background(configuration.isPressed ? selectedBackground : background)
      .cornerRadius(radius)
  }
}

struct KeyButton: View {
  var label: String
  var style: KeyButtonStyle = KeyButtonStyle()
  var action: () -> Void
  
  var body: some View {
    Button(label, action: action)
      .buttonStyle(style)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
