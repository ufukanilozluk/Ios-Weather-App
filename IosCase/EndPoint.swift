//
//  EndPoint.swift
//  IosCase
//
//  Created by Ufuk Anıl Özlük on 18.01.2023.
//

import Foundation

struct Endpoint {
    var host: String
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/" + path
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }

        return url
    }
}

extension Endpoint {
    static func daily(
        city: String,
        cnt: String = "7",
        lang: String = "en",
        appId: String = "54bfbfe4aa755c3b005fded2b0741fa5",
        units: String = "metric"
    ) -> Self {
        Endpoint(
            host: "api.openweathermap.org",
            path: "data/2.5/forecast",
            queryItems: [
                URLQueryItem(name: "appid", value: appId),
                URLQueryItem(name: "cnt", value: cnt),
                URLQueryItem(name: "lang", value: lang),
                URLQueryItem(name: "units", value: units),
                URLQueryItem(name: "q", value: city),
            ]
        )
    }

    static func weeklyForecast(
        exclude: String?,
        lan: String,
        lot: String,
        appId: String = "54bfbfe4aa755c3b005fded2b0741fa5"
    ) -> Self {
        Endpoint(
            host: "api.openweathermap.org",
            path: "onecall",
            queryItems: [
                URLQueryItem(name: "appid", value: appId),
                URLQueryItem(name: "exclude", value: exclude),
                URLQueryItem(name: "lot", value: lot),
                URLQueryItem(name: "lan", value: lan),
            ]
        )
    }
}