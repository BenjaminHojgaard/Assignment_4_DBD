package com.example.demo.model;

import lombok.Data;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;
import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;

import java.util.ArrayList;
import java.util.List;

import static org.neo4j.ogm.annotation.Relationship.INCOMING;

@Data
@NodeEntity
public class NodeModel {
    @Id
    @GeneratedValue
    Long Id;

    String name;

    @Relationship(type = "PART_OF", direction = INCOMING)
    private List<NodeDomain> nodeDomains = new ArrayList<>();
}
