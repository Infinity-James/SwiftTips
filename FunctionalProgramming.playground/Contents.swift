import Combine
import Foundation

func sum(_ x: Int, _ y: Int, _ z: Int) -> Int {
	x + y + z
}

//  MARK: TOTAL
/**
A function provides an output for every possible input.
*/
enum DivisionError: Error {
	case zeroDividend
}
func divide(_ x: Double, _ y: Double) -> Result<Double, DivisionError> {
	guard y != 0 else { return .failure(DivisionError.zeroDividend) }
	return .success(x / y)
}

//  MARK: DETERMINISTIC
/**
A function always returns the same value for a given input.
*/
func filename(prefix: String, extension: String, date: Date = Date()) -> String {
	return "\(prefix)-\(date).\(`extension`)"
}

//  MARK: PURE
/**
A function only computes its result and performs no side effect.
*/
func greet(_ name: String) {
	//	impure
	print("Hello, \(name).")
}
greet("James")
func greet2(_ name: String) -> AnyPublisher<Void, Never> {
	//	encapsulate side effects, moving impurities to another layer
	//	this will still run the side effects immediately though
	Future { promise in
		print("Hello, \(name).")
		promise(.success(()))
	}
	.eraseToAnyPublisher()
}
greet2("Mr. Valaitis")
func greet3(_ name: String) -> AnyPublisher<Void, Never> {
	//	side effects are lazily evaluated only when there is a listener
	Deferred {
		Future { promise in
			print("Hello, \(name).")
			promise(.success(()))
		}
	}
	.eraseToAnyPublisher()
}

let test = greet3("You Sexy Devil")
//	this will run the side effects:
//test.sink { _ in }

//	both are run
greet2("Run Twice")
	.flatMap { _ in greet2("Run Twice") }
	.sink { _ in }


//	only run once now
let publisher = greet2("Run Once")
publisher.flatMap { _ in publisher }.sink { _ in }

//	both are run in both case
greet3("Deferred Run Twice")
	.flatMap { _ in greet2("Deferred Run Twice") }
	.sink { _ in }
let deferredPublisher = greet3("Deferred Still Run Twice")
deferredPublisher.flatMap { _ in deferredPublisher }.sink { _ in }

//  MARK: Composition
func compose<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
	{ a in g(f(a)) }
}

func compose<A, B, C>(_ f: @escaping (A) -> B?, _ g: @escaping (B) -> C) -> (A) -> C? {
	{ a in f(a).map(g) }
}

func compose<A, B, C>(_ f: @escaping (A) -> [B], _ g: @escaping (B) -> C) -> (A) -> [C] {
	{ a in f(a).map(g) }
}

func compose<A, B, C>(_ f: @escaping (A) -> Result<B, Error>, _ g: @escaping (B) -> C) -> (A) -> Result<C, Error> {
	{ a in f(a).map(g) }
}

//func compose<A, B, C, F: Functor>(_ f: @escaping (A) -> F<B>, _ g: @escaping (B) -> C) -> (A) -> F<C> {
//	{ a in f(a).map(g) }
//}

func compose<A, B, C>(_ f: @escaping (A) -> B?, _ g: @escaping (B) -> C?) -> (A) -> C? {
	{ a in f(a).flatMap(g) }
}

func compose<A, B, C>(_ f: @escaping (A) -> [B], _ g: @escaping (B) -> [C]) -> (A) -> [C] {
	{ a in f(a).flatMap(g) }
}

func compose<A, B, C>(_ f: @escaping (A) -> Result<B, Error>, _ g: @escaping (B) -> Result<C, Error>) -> (A) -> Result<C, Error> {
	{ a in f(a).flatMap(g) }
}

//func compose<A, B, C, F: Monad>(_ f: @escaping (A) -> F<B>, _ g: @escaping (B) -> F<C>) -> (A) -> F<C> {
//	{ a in f(a).flatMap(g) }
//}

func zip<A, B, C>(_ a: A?, _ b: B?, _ f: @escaping (A, B) -> C) -> C? {
	a.flatMap { a in b.map { b in f(a, b) } }
}
