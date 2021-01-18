import Foundation
import UIKit

//  MARK: Prefix
let currencyFormatter = NumberFormatter()
currencyFormatter.numberStyle = .currency
currencyFormatter.locale = Locale.current

let priceString = currencyFormatter.string(from: 1799.99)!
print(priceString)

internal prefix func ~(value: NSNumber) -> String {
	let currencyFormatter = NumberFormatter()
	currencyFormatter.numberStyle = .currency
	currencyFormatter.locale = Locale.current
	return currencyFormatter.string(from: value)!
}

let monsterPackPrice = ~7.99
print(monsterPackPrice)

//  MARK: Postfix
postfix operator %
internal postfix func %(percentage: Int) -> Float {
	Float(percentage) / 100
}
let progressView = UIProgressView()
progressView.progress = 45%

//  MARK: Infix
let firstNumbers: Set<Int> = [1, 2, 3, 5]
let secondNumbers: Set<Int> = [2, 3, 5, 7]

infix operator +-: AdditionPrecedence
internal extension Set {
	static func +-(lhs: Set, rhs: Set) -> Set {
		lhs.union(rhs)
	}
}

let allNumbers = firstNumbers +- secondNumbers
print(allNumbers)

//  MARK: Custom Compound Assignment
internal struct Member: CustomDebugStringConvertible {
	let name: String
	var debugDescription: String { name }
}
internal struct Team {
	let title: String
	private(set) var members: [Member]
	
	mutating func add(_ member: Member) {
		members.append(member)
	}
}

var team = Team(title: "Philosophers", members: [Member(name: "Sam Harris"),
												 Member(name: "Daniel Dennett"),
												 Member(name: "David Deutsch")])
team.add(Member(name: "Susan Blackmore"))

internal extension Team {
	static func +=(lhs: inout Team, rhs: Member) {
		lhs.add(rhs)
	}
	
	static func +=(lhs: inout Team, rhs: Team) {
		lhs.members.append(contentsOf: rhs.members)
	}
}

team += Member(name: "Adam Smith")

print(team.members)

let teamTwo = Team(title: "Existentialists", members: [Member(name: "Jean Paul Sartre"),
													   Member(name: "Søren Kierkegaard"),
													   Member(name: "Albert Camus")])

team += teamTwo
print(team.members)


