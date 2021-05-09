package com.example.demo.repository;

import com.example.demo.model.NodeDomain;
import com.example.demo.model.NodeType;
import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;

@Repository
public interface NodeDomainRepository extends Neo4jRepository<NodeDomain, Long> {

    @Query("match (TestCase:NodeType {name: $NodeTypeName}), (Process:NodeDomain {name: $NodeDomainName}), p = shortestPath((TestCase)-[*]-(Process))\n" +
            "WHERE length(p) > 1 return p")
    Collection<NodeDomain> shortestPath(@Param("NodeTypeName") String NodeTypeName, @Param("NodeDomainName") String NodeDomainName);
}
