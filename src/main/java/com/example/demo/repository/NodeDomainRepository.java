package com.example.demo.repository;

import com.example.demo.model.NodeDomain;
import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.stereotype.Repository;

import java.util.Collection;

@Repository
public interface NodeDomainRepository extends Neo4jRepository<NodeDomain, Long> {

    @Query("MATCH (n:NodeDomain)<-[r:INCLUDED_IN]-(t:NodeType) return n, r, t")
    Collection<NodeDomain> findAllNodeDomains();


}
