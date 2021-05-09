package com.example.demo.repository;

import com.example.demo.model.NodeType;
import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;

import java.util.Collection;

public interface NodeTypeRepository extends Neo4jRepository<NodeType, Long> {
    @Query("MATCH (n:NodeDomain)<-[r:INCLUDED_IN]-(t:NodeType) return t")
    Collection<NodeType> findAllNodeTypes();


}
