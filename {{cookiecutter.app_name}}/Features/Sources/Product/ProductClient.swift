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

struct ProductClient {
  var getProduct: any ProductUseCaseType
  var saveProduct: any SaveProductUseCaseType
  var prepareCoreData: any PrepareCoreDataUseCaseType

  init(
    _ prepare: PrepareCoreDataUseCase,
    getProductUseCase: ProductUseCase,
    saveProductUseCase: SaveProductUseCase
  ) {
    self.prepareCoreData = prepare
    self.getProduct = getProductUseCase
    self.saveProduct = saveProductUseCase
  }
}

extension DependencyValues {
  var appClient: ProductClient {
    get { self[ProductClient.self] }
    set { self[ProductClient.self] = newValue }
  }
}

extension ProductClient: DependencyKey {
  public static var liveValue = ProductClient(
    PrepareCoreDataUseCase(repository: PreparePersistentRepository.live),
    getProductUseCase: ProductUseCase(repository: RemoteProductRepository.live),
    saveProductUseCase: SaveProductUseCase(
      repository: PersistentProductRepository.live))
  public static var testValue = ProductClient(
    PrepareCoreDataUseCase(repository: PreparePersistentRepository.live),
    getProductUseCase: ProductUseCase(repository: RemoteProductRepository.stubbed),
    saveProductUseCase: SaveProductUseCase(
      repository: PersistentProductRepository.live))
  public static var previewValue = ProductClient(
    PrepareCoreDataUseCase(repository: PreparePersistentRepository.live),
    getProductUseCase: ProductUseCase(repository: RemoteProductRepository.stubbed),
    saveProductUseCase: SaveProductUseCase(
      repository: PersistentProductRepository.live))
}
