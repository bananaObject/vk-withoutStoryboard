//
//  RealmLayer.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 15.03.2022.
//

import Foundation
import RealmSwift

// MARK: - Extension
extension RealmLayer {
    /// Перечисление ошибок работы с Realm.
    enum Errors: Error {
        case noRealmObject(String)
        case noPrimatyKey(String)
        case failedToRead(String)
        case other(String)
    }
}

/// Класс для работы с Realm.
final class RealmLayer {
    // MARK: - Private Properties
    private var realm: Realm

    // MARK: - Initializers
    /// Создается экземпляр Realm,  представляет базу данных.
    /// - Parameter migration: Если для этого свойства задано значение true, файл удаляется.
    ///
    ///  Migration - полезна при изменениях свойст модели в базе данных.
    ///  По умолчанию отключена.
    init(deleteRealmIfMigrationNeeded migration: Bool = false) {
        do {
            if migration {
                var config: Realm.Configuration = Realm.Configuration()
                // Если меняется модель в realm базе
                config.deleteRealmIfMigrationNeeded = true
                self.realm = try Realm(configuration: config)
            } else {
                self.realm = try Realm()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - Public Methods
    /// Выводит в консоль локальный адрес файла Realm
    func printUrlFile() {
        guard let url: URL = realm.configuration.fileURL else {
            printError(Errors.other("No url file Realm"))
            return
        }
        print("#FILE_Realm: \(url)")
    }

    /// Выполняет действия, содержащиеся в данном блоке внутри транзакции записи.
    /// - Parameter block: Замыкание.
    func writeTransction(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            printError(error)
        }
    }

    /// Возвращает все объекты данного типа, хранящиеся в Realm.
    /// - Parameter object: тип возвращаемых объектов.
    /// - Returns: `Results` содержащий объекты.
    func read<T: Object>(_ object: T.Type) -> Results<T> {
        return realm.objects(T.self)
    }

    /// Извлекает единственный экземпляр данного типа объекта с заданным первичным ключом из Realm.
    /// - Parameters:
    ///   - object: тип возвращаемого объекта.
    ///   - key: Primary Key объекта
    ///   - completion: Замыкание.  Передает : `Result` `.success` - содержащий экземпляр объект  или `.failure` - содержащий ошибку
    func read<T: Object>(
        _ object: T.Type,
        key: Any,
        completion: @escaping (Result<T, Error>) -> Void) {
            if let result: T = realm.object(ofType: T.self, forPrimaryKey: key) {
                completion(.success(result))
            } else {
                completion(.failure(Errors.failedToRead("Fail to read object")))
            }
        }

    /// Добавляет неуправляемый объект в  Realm.
    /// - Parameter object: Объект, который нужно добавить в Realm.
    ///
    /// Запись массивом более быстрее, чем по одному. Так как открытие транзакции записи занимает прилично времени.
    func create<T: Object>(object: T) {
        // первый вариант записи в реалм
        do {
            try realm.write {
                // .modified - перезапишет существующий объект
                realm.add(object, update: .modified)
            }
        } catch {
            printError(error)
        }
    }

    /// Записывает неуправляемые объекты в  Realm.
    /// - Parameter objects: Список объектов, который нужно добавить в Realm.
    func create<T: Object>(objects: [T]) {
        // второй вариант записи в реалм
        do {
            realm.beginWrite()
            realm.add(objects, update: .modified)
            try realm.commitWrite()
        } catch {
            printError(error)
        }
    }

    /// Удаляет объект из Realm.
    /// - Parameter object: Объект, который необходимо удалить.
    func delete<T: Object>(object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            printError(error)
        }
    }

    /// Удаляет объекты из Realm.
    /// - Parameter objects: `Results` содержащий объекты, который необходимо удалить.
    func delete<T: Object>(objects: Results<T>) {
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            printError(error)
        }
    }

    /// Удаляет объекты из Realm.
    /// - Parameter objects: Список объектов, который необходимо удалить.
    func delete<T: Object>(objects: [T]) {
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            printError(error)
        }
    }

    func deleteWithoutNotifying<T: Object>(objects: [T], token: NotificationToken) {
        do {
            try realm.write(withoutNotifying: [token]) {
                realm.delete(objects)
            }
        } catch {
            printError(error)
        }
    }

    // MARK: - Private Methods
    private func printError(_ error: Error) {
        print("#ERROR_RealmService: \(error)")
    }
}
