//
//  ProductClient.swift
//  Features
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Dependencies
import Domain
import Foundation
import NetworkPlatform
import PersistentPlatform

struct ProductClient: Sendable {
  var prepareCoreData: any PrepareCoreDataUseCaseType
  var getProduct: any ProductUseCaseType
  var saveProduct: any SaveProductUseCaseType
  var observeProducts: any ObserveProductsUseCaseType
  var observeReachability: any ObserveReachabilityUseCaseType
  var observeNetworkActivity: any ObserveNetworkActivityUseCaseType
}

extension DependencyValues {
  var productClient: ProductClient {
    get { self[ProductClient.self] }
    set { self[ProductClient.self] = newValue }
  }
}

extension ProductClient: DependencyKey {
  static let liveValue = ProductClient(
    prepareCoreData: PrepareCoreDataUseCase(repository: PreparePersistentRepository.live),
    getProduct: ProductUseCase(repository: RemoteProductRepository.live),
    saveProduct: SaveProductUseCase(repository: PersistentProductRepository.live),
    observeProducts: ObserveProductsUseCase(repository: PersistentProductRepository.live),
    observeReachability: ObserveReachabilityUseCase(repository: ReachabilityRepository.live),
    observeNetworkActivity: ObserveNetworkActivityUseCase(
      repository: NetworkActivityRepository.live))

  /// Stubbed network responses and an in-memory store.
  static let testValue = ProductClient(
    prepareCoreData: PrepareCoreDataUseCase(repository: PreparePersistentRepository.stubbed),
    getProduct: ProductUseCase(repository: RemoteProductRepository.stubbed),
    saveProduct: SaveProductUseCase(repository: PersistentProductRepository.stubbed),
    observeProducts: ObserveProductsUseCase(repository: PersistentProductRepository.stubbed),
    observeReachability: ObserveReachabilityUseCase(repository: ReachabilityRepository.online),
    observeNetworkActivity: ObserveNetworkActivityUseCase(
      repository: NetworkActivityRepository.live))

  static let previewValue = testValue
}
