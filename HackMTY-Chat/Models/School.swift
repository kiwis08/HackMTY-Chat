//
//  School.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Foundation

struct School: Codable, Hashable {
    var name: String
    var country: String
    var stateProvince: String?
    var websites: [String]
    var countryCode: String
    var domains: [String]
    
    static let example = School(name: "Select your school", country: "Mexico", state: nil, websites: [], countryCode: "", domains: [])
    
    init(name: String, country: String, state: String?, websites: [String], countryCode: String, domains: [String]) {
        self.name = name
        self.country = country
        self.stateProvince = state
        self.websites = websites
        self.countryCode = countryCode
        self.domains = domains
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.name = try container.decode(String.self, forKey: .name)
            self.country = try container.decode(String.self, forKey: .country)
            self.stateProvince = try container.decodeIfPresent(String.self, forKey: .stateProvince)
            self.websites = try container.decode([String].self, forKey: .websites)
            self.countryCode = try container.decode(String.self, forKey: .countryCode)
            self.domains = try container.decode([String].self, forKey: .domains)
        } catch {
            print(error)
            throw SchoolDecodeError.invalidType
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case country
        case stateProvince = "state-province"
        case websites = "web_pages"
        case countryCode = "alpha_two_code"
        case domains
    }
    
    fileprivate enum SchoolDecodeError: Error {
        case invalidType
    }
}
