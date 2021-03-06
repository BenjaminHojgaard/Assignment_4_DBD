package com.example.demo.model;

import lombok.Data;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;
import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;

import java.util.ArrayList;
import java.util.List;

import static org.neo4j.ogm.annotation.Relationship.INCOMING;
import static org.neo4j.ogm.annotation.Relationship.OUTGOING;

@NodeEntity
@Data
public class NodeDomain {

    @Id
    @GeneratedValue
    Long Id;

    String name, description;
    @Relationship(type = "INCLUDED_IN", direction = INCOMING)
    private List<NodeType> nodeTypes = new ArrayList<>();


    @Relationship(type = "PART_OF", direction = OUTGOING)
    private List<NodeModel> nodeModels = new ArrayList<>();
}
