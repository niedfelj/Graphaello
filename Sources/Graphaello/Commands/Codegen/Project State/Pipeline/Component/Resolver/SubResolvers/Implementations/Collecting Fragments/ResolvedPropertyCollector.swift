//
//  ResolvedPropertyCollector.swift
//  Graphaello
//
//  Created by Mathias Quintero on 09.12.19.
//  Copyright © 2019 Mathias Quintero. All rights reserved.
//

import Foundation

struct ResolvedPropertyCollector<Collector: ResolvedValueCollector>: ResolvedValueCollector where Collector.Resolved == Stage.Validated.Component, Collector.Parent == Stage.Resolved.Path, Collector.Collected == CollectedPath.Valid {
    let collector: Collector
    
    func collect(from value: Property<Stage.Resolved>,
                 in parent: Struct<Stage.Resolved>) throws -> StructResolution.Result<StructResolution.CollectedValue?> {
        
        guard let path = value.graphqlPath else { return .resolved(nil) }
        return try path
            .validated
            .components
            .collect { component in
                return try collector.collect(from: component, in: path)
            }
            .map { components in
                return components.reduce(.empty) { $0 + $1 }
            }
            .map { collectedPath in
                guard case .valid(let collectedPath) = collectedPath else { throw GraphQLFragmentResolverError.cannotResolveFragmentOrQueryWithEmptyPath(path) }
                
                switch path.validated.parsed.target {
                    
                case .query:
                    let components = try collectedPath.queryComponents(propertyName: value.name)
                    return .query(GraphQLQuery(name: parent.name, api: path.validated.api, components: components))
                
                case .object:
                    let simpleDefinitionName = parent.name.replacingOccurrences(of: #"[\[\]\.\?]"#, with: "", options: .regularExpression)
                    let object = collectedPath.object(propertyName: value.name)
                    let fragment = GraphQLFragment(name: "\(simpleDefinitionName)\(path.validated.target.name)", api: path.validated.api, target: path.validated.target, object: object)
                    
                    return .fragment(fragment)
                }
            }
    }
}

extension ResolvedPropertyCollector {
    
    init(collector: () -> Collector) {
        self.collector = collector()
    }
    
}