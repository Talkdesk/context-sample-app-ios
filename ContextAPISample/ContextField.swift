//
//  ContextField.swift
//  ContextAPISample
//
//  Copyright © 2018 Talkdesk. All rights reserved.
//

import Foundation

enum ContextDataType: String, Codable {
    case phone
    case text
    case url
}

struct ContextField: Codable {
    let name: String
    let displayName: String
    let tooltipText: String
    let dataType: ContextDataType
    let value: String

    enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
        case tooltipText = "tooltip_text"
        case dataType = "data_type"
        case value
    }
}
