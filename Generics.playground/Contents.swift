import Foundation

//  MARK: Data Store
public struct Cache<Local: LocalStore, Remote: RemoteStore> where Local.StoredType == Remote.StoredType {
	private let localStore: Local
	private let remoteStore: Remote
	
	public init(localStore: Local, remoteStore: Remote) {
		self.localStore = localStore
		self.remoteStore = remoteStore
	}
	
	func fetch(_ identifier: String, completion: @escaping (Result<Local.StoredType, Error>) -> ()) {
		if let item = localStore.fetch(identifier) { completion(.success(item)) }
		else {
			remoteStore.fetch(identifier) { result in
				switch result {
				case .failure(let error): completion(.failure(error))
				case .success(let item):
					localStore.persist(item)
					completion(.success(item))
				}
			}
		}
	}
}

//  MARK: Local Store
public protocol LocalStore {
	associatedtype StoredType
	func fetch(_ identifier: String) -> StoredType?
	func persist(_ item: StoredType)
}

//  MARK: Local Store
public protocol RemoteStore {
	associatedtype StoredType
	func fetch(_ identifier: String, completion: @escaping (Result<StoredType, Error>) -> ())
}

//  MARK: Concrete Implementation
internal struct User {
	let name: String
}

internal struct UserDataStore: LocalStore {
	func fetch(_ identifier: String) -> User? { nil }
	func persist(_ item: User) { }
}


internal struct UserAPI: RemoteStore {
	func fetch(_ identifier: String, completion: @escaping (Result<User, Error>) -> ()) { completion(.failure(NSError())) }
}

let cache = Cache(localStore: UserDataStore(), remoteStore: UserAPI())
cache.fetch("james") { result in
	switch result {
	case .failure(let error): print("Failed to fetch user: \(error.localizedDescription)")
	case .success(let user): print("User fetched: \(user.name)")
	}
}
