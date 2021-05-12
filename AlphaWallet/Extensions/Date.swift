//
//  Date.swift
//  Alpha-Wallet
//
//  Created by Oguzhan Gungor on 2/24/18.
//  Copyright © 2018 Alpha-Wallet. All rights reserved.
//

import Foundation

private class ThreadSafeDateFormattersCache {
    fileprivate var cache = [String: DateFormatter]()
    private let queue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)

    subscript(format: String) -> DateFormatter? {
        get {
            var element: DateFormatter?
            queue.sync {
                element = cache[format]
            }
            return element
        }
        set {
            queue.async(flags: .barrier) {
                self.cache[format] = newValue
            }
        }
    }

    func reset() {
        self.cache.removeAll()
    }
}

public extension Date {
    private static var formatsMap = ThreadSafeDateFormattersCache()
    private static var formatsMapLocale: String?

    init?(string: String, format: String) {
        let date = Date.formatter(with: format).date(from: string)
        if date != nil {
            self = date!
            return
        }
        return nil
    }

    //TODO fix function name. It's returning a string
    func format(_ format: String, withTimeZone timezone: TimeZone? = nil) -> String {
        return Date.formatter(with: format, withTimeZone: timezone).string(from: self)
    }

    static func formatter(with format: String, withTimeZone timeZone: TimeZone? = nil) -> DateFormatter {
        if Config.getLocale() != formatsMapLocale {
            formatsMapLocale = Config.getLocale()
            formatsMap.reset()
        }

        var foundFormatter: DateFormatter? = formatsMap[format]
        if foundFormatter == nil {
            foundFormatter = DateFormatter()
            if let locale = Config.getLocale() {
                foundFormatter?.locale = Locale(identifier: locale)
            }
            foundFormatter?.setLocalizedDateFormatFromTemplate(format)
            formatsMap[format] = foundFormatter!
        }
        if let timeZone = timeZone {
            foundFormatter?.timeZone = timeZone
        } else {
            foundFormatter?.timeZone = .current
        }
        return foundFormatter!
    }

    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }

    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }

    func formatAsShortDateString(withTimezone timezone: TimeZone? = nil) -> String {
        return format("dd MMM yyyy", withTimeZone: timezone)
    }

    func isEarlierThan(date: Date) -> Bool {
        return date.timeIntervalSince(self) > 0
    }
}
