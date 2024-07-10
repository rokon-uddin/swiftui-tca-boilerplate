//
//  Stubbable.swift
//  NetworkPlatform
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Foundation

protocol Stubble {

}

extension Stubble {
  func stubbedResponse(_ filename: String) -> Data! {
    let path = Bundle.module.path(
      forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
  }
}
