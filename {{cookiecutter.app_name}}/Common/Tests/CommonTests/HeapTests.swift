//
//  HeapTests.swift
//  CommonTests
//
//  Created by {{cookiecutter.creator}} on {% now 'utc', '%d/%m/%Y' %}.
//  Copyright © {% now 'utc', '%Y' %} {{cookiecutter.company_name}}. All rights reserved.
//

import Testing

@testable import Common

struct HeapTests {
  struct Node: Equatable {
    @Heap var value: Int
  }

  @Test func copiesHaveValueSemantics() {
    var original = Node(value: Heap(1))
    let copy = original
    original.value = 2

    #expect(original.value == 2)
    #expect(copy.value == 1)
  }

  @Test func isSendableAcrossTasks() async {
    let heap = Heap(41)
    let result = await Task.detached { heap.wrappedValue + 1 }.value
    #expect(result == 42)
  }
}
