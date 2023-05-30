//
//  Application+Extension.swift
//  
//
//  Created by Cole M on 5/30/23.
//

import Vapor
import Fluent

public protocol RequestService {
    func `for`(_ req: Request) -> Self
}

public protocol DatabaseRepository: Repository {
    var database: Database { get }
    init(database: Database)
}

public extension DatabaseRepository {
    func `for`(_ req: Request) -> Self {
        return Self.init(database: req.db)
    }
}

public protocol Repository: RequestService {}

extension Application {
    struct Repositories {
        struct Provider {
            static var database: Self {
                .init {
                    $0.repositories.use { DatabaseOrderRepository(database: $0.db) }
                }
            }
            let run: (Application) -> ()
        }
        
        final class Storage {
            var makeOrderRepository: ((Application) -> OrderRepository)?
            init() { }
        }
        
        struct Key: StorageKey {
            typealias Value = Storage
        }
        
        let app: Application
        
        func use(_ provider: Provider) {
            provider.run(app)
        }
        
        var storage: Storage {
            if app.storage[Key.self] == nil {
                app.storage[Key.self] = .init()
            }
            
            return app.storage[Key.self]!
        }
    }
    
    var repositories: Repositories {
        .init(app: self)
    }
}

