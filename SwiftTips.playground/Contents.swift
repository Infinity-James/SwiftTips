import Foundation
import XCTest
import UIKit

//  MARK: #1: Typealias and Functions

typealias ID = Int
typealias CompletionHandler<T> = (Result<T, Error>) -> (Void)

func fetchUserName(userID: ID, completion: @escaping CompletionHandler<String>) {
	
}

//  MARK: #2: Transforming an Optional with Map
let date: Date? = Bool.random() ? Date() : nil
let formatter = DateFormatter()
let label = UILabel()
label.text = date.flatMap(formatter.string(from:))

//  MARK: #3: ExpressibleByStringLiteral
let url = URL(string: "https://google.co.uk")!
extension URL: ExpressibleByStringLiteral {
	public init(stringLiteral value: StaticString) {
		self.init(string: "\(value)")!
	}
}
let url2: URL = "https://google.co.uk"
let request = URLRequest(url: "https://google.co.uk")

//  MARK: #4: Safely Subscripting an Array
let data = [1, 2, 3]
extension Array {
	subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}
data[safe: 5]

//  MARK: #5: Custom and Compiler Generated Init
struct Point {
	let x: Int
	let y: Int
}
extension Point {
	init() {
		x = 0
		y = 0
	}
}
Point()
Point(x: 0, y: 0)

//  MARK: #6: Autoclosure
func log(_ message: @autoclosure () -> String) {
	#if DEBUG
	print(message())
	#endif
}


let response = URLResponse()
log(response.debugDescription)

//  MARK: #7: KeyPath and Higher Order Functions
let numbers = [1, 5, 6, 11, 19, 34, 56]
// KeyPath<Root, value> => (Root) -> Value
let strings = numbers.map(\.description)

//  MARK: #8: XCTUnwrap
//class MyTests: XCTestCase {
//	func test() throws {
//		let data = [1, 2, 3]
//		let first = try XCTUnwrap(data.first)
//		XCTAssert(first < 3)
//	}
//}

//  MARK: #9: #File, #Line, and #Function
func _log(_ message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
	print("[\(file): \(line)] \(function) - \(message)")
}

_log("Message")

//  MARK: #10: String?.orEmpty
let textField = UITextField()
textField.text ?? ""
extension Optional where Wrapped == String {
	var orEmpty: String {
		switch self {
		case .none: return ""
		case .some(let value): return value
		}
	}
}
textField.text.orEmpty

//  MARK: #11: For Where
let numbersToLoop = [3, 5, 7, 9, 10, 11, 18, 23, 28]
for number in numbersToLoop {
	if number.isMultiple(of: 2) {
		print("Even number: \(number)")
	}
}
for number in numbersToLoop where number.isMultiple(of: 2) {
	print("Even number: \(number)")
}

//  MARK: #12: Multiple Line Strings
let naiveMultipleLineString = "This goes\nover multiple\nlines."
naiveMultipleLineString
let betterMultipleLineString = """
This goes
over multiple
lines.
"""
betterMultipleLineString
betterMultipleLineString == naiveMultipleLineString

//  MARK: #13: Private(Set)
struct Person {
	let id: UUID
	private(set) var name: String
	let canChangeName: Bool
	
	mutating func attemptNameChange(to newName: String) {
		guard canChangeName else { return }
		name = newName
	}
}

var james = Person(id: UUID(), name: "James", canChangeName: true)
james.name
james.attemptNameChange(to: "Epictetus")
james.name

//  MARK: #14: Property Wrappers
func showAppIntro() { }

extension UserDefaults {
	private enum Keys {
		static let hasSeenIntro = "has_seen_intro"
	}
	
	var hasSeenIntro: Bool {
		set { set(newValue, forKey: Keys.hasSeenIntro) }
		get { bool(forKey: Keys.hasSeenIntro) }
	}
}

if !UserDefaults.standard.hasSeenIntro {
	showAppIntro()
	UserDefaults.standard.hasSeenIntro = true
}

@propertyWrapper
struct UserDefault<Value> {
	let key: String
	let defaultValue: Value
	var wrappedValue: Value {
		set { UserDefaults.standard.set(newValue, forKey: key) }
		get { UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue }
	}
	
	init(key: String, defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
	}
	
	var projectedValue: Self { get { self } }
	
	func removeValue() {
		UserDefaults.standard.removeObject(forKey: key)
	}
}

struct UserDefaultsValues {
	@UserDefault(key: "hasSeenAppIntro", defaultValue: false)
	static var hasSeenAppIntro: Bool
}

UserDefaultsValues.hasSeenAppIntro = false
UserDefaultsValues.hasSeenAppIntro

UserDefaultsValues.hasSeenAppIntro = true
UserDefaultsValues.hasSeenAppIntro

UserDefaultsValues.$hasSeenAppIntro.removeValue()

UserDefaultsValues.hasSeenAppIntro

//  MARK: #15: Enumerated
let peopleNames = ["James", "Daniel", "Matthew", "Lewis", "Abby", "Mark"]
for (index, name) in peopleNames.enumerated() {
	print("At \(index) in \(name).")
}

//  MARK: #16: Discardable Result
@discardableResult
func __log(_ message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) -> String {
	let message = "[\(file): \(line)] \(function) - \(message)"
	print(message)
	return message
}

func businessLogic() {
	__log("Hey, world!")
}

businessLogic()

//  MARK: #17: String Interpolation
let basicStringInterpolation = "2⁶ = \(pow(2, 6))"

struct User {
	var firstName: String
	var lastName: String
}

let legendaryUser = User(firstName: "Daniel", lastName: "Kahneman")

extension String.StringInterpolation {
	mutating func appendInterpolation(user: User) {
		appendInterpolation("My name is \(user.firstName) \(user.lastName)")
	}
	
	mutating func appendInterpolation(localized key: String, _ args: CVarArg...) {
		let localized = String(format: NSLocalizedString(key, comment: ""), args)
		appendLiteral(localized)
	}
}

print("\(legendaryUser)")
print("\(user: legendaryUser)")
print("\(localized: "welcome.screen.greetings", legendaryUser.firstName)")

//  MARK: #18: Result
func fetchBookName(for identifier: String, completion: @escaping (Result<String, Error>) -> ()) { }
fetchBookName(for: "kahneman-2") { result in
	switch result {
	case .failure(let error):
		print(error)
	case .success(let bookName):
		print(bookName)
	}
}

//  MARK: #19: Zip
let indices = [1, 2, 6, 9, 15, 17, 21, 33]
let labels = ["UNLOCKED", "Music To Be Murdered By", "SAVAGE MODE II", "RTJ4", "The Allegory"]

for idx in 0..<min(indices.count, labels.count) {
	print("\(indices[idx]). \(labels[idx])")
}

for (idx, label) in zip(indices, labels) {
	print("\(idx). \(label)")
}

//  MARK: #20: StaticString
extension URL {
	init(staticString: StaticString) {
		self.init(string: "\(staticString)")!
	}
}
let path = "maps"
let googleStaticURL = URL(staticString: "https://google.co.uk/")
let googleDynamicURL = URL(string: "https://google.co.uk/\(path)")!

//  MARK: #21: callAsFunction & #22: @dynamicMemberLookup
@dynamicMemberLookup
internal struct CellConfigurator<Model, Cell: UITableViewCell> {
	let model: Model
	let configurator: (Model, Cell) -> Void
	
	func callAsFunction(_ cell: Cell) {
		configurator(model, cell)
	}
	
	subscript<T>(dynamicMember keyPath: KeyPath<Model, T>) -> T { model[keyPath: keyPath] }
}
let cell = UITableViewCell()
let me = Person(id: UUID(), name: "James", canChangeName: false)

let configurator = CellConfigurator(model: me) { model, cell in
	cell.textLabel?.text = model.name
}

configurator(cell)
configurator.name

//  MARK: Bonus: Regular Expression
private final class PersonViewController: UIViewController {
	@IBOutlet private weak var firstName: UITextField!
	@IBOutlet private weak var lastName: UITextField!
	@IBOutlet private weak var age: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = NSLocalizedString("person.title", comment: "")
		firstName.placeholder = NSLocalizedString("person.firstName.placeholder", comment: "")
		lastName.placeholder = NSLocalizedString("person.lastName.placeholder", comment: "")
		age.placeholder = NSLocalizedString("person.lastName.placeholder", comment: "")
	}
}

/**
Replace > Regular Expression
NSLocalizedString\((".*"), comment: ""\)
with
$1.localized
*/
private extension String {
	var localized: String { NSLocalizedString(self, comment: "") }
}

//  MARK: Bonus: Weak Self
internal final class Service {
	func call(with completion: @escaping (Int) -> ()) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) { completion(7) }
	}
}

internal final class ViewController: UIViewController {
	let service = Service()
	let label = UILabel()

	func format(_ data: Int) -> String { "\(data)" }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		label.text = "Retreieved data: "
		service.call(with: weak { `self`, data in self.label.text?.append(self.format(data)) })
	}
}

public protocol Weak: class { }
extension NSObject: Weak { }
extension Weak {
	func weak<T>(f: @escaping (Self, T) -> ()) -> ((T) -> ()) {
		{ [weak self] data in
			guard let self = self else { return }
			f(self, data)
		}
	}
}
