package com.example.demo.model;

import lombok.Data;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;
import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;

import java.util.ArrayList;
import java.util.List;

import static org.neo4j.ogm.annotation.Relationship.OUTGOING;
import static org.neo4j.ogm.annotation.Relationship.UNDIRECTED;

@Data
@NodeEntity
public class NodeType {
    @Id
    @GeneratedValue
    Long id;
    String name, description;

    @Relationship(type = "INCLUDED_IN", direction = OUTGOING)
    private List<NodeDomain> nodeDomains = new ArrayList<>();

    @Relationship(type = "INCLUDED_IN", direction = UNDIRECTED)
    private List<NodeType> includedIn = new ArrayList<>();

    @Relationship(type = "INTENDED_FOR", direction = UNDIRECTED)
    private List<NodeType> intendedFor = new ArrayList<>();

    @Relationship(type = "LOCATED_IN", direction = UNDIRECTED)
    private List<NodeType> locatedIn = new ArrayList<>();

    @Relationship(type = "PART_OF", direction = UNDIRECTED)
    private List<NodeType> partOf = new ArrayList<>();

    @Relationship(type = "USES", direction = UNDIRECTED)
    private List<NodeType> uses = new ArrayList<>();

    @Relationship(type = "REFERENCES", direction = UNDIRECTED)
    private List<NodeType> references = new ArrayList<>();

    @Relationship(type = "REPORTED_IN", direction = UNDIRECTED)
    private List<NodeType> reportedIn = new ArrayList<>();

    @Relationship(type = "DEFINED_IN", direction = UNDIRECTED)
    private List<NodeType> definedIn = new ArrayList<>();

    @Relationship(type = "DEPLOYED_TO", direction = UNDIRECTED)
    private List<NodeType> deployedTo = new ArrayList<>();

    @Relationship(type = "KNOWS_ABOUT", direction = UNDIRECTED)
    private List<NodeType> knowsAbout = new ArrayList<>();

    @Relationship(type = "AFFECTS", direction = UNDIRECTED)
    private List<NodeType> affects = new ArrayList<>();

    @Relationship(type = "RELATES_TO", direction = UNDIRECTED)
    private List<NodeType> relatesTo = new ArrayList<>();

    @Relationship(type = "MEMBER_OF", direction = UNDIRECTED)
    private List<NodeType> memberOf = new ArrayList<>();

    @Relationship(type = "ASSIGNED_TO", direction = UNDIRECTED)
    private List<NodeType> assignedTo = new ArrayList<>();

    @Relationship(type = "APPLIES_TO", direction = UNDIRECTED)
    private List<NodeType> appliedTo = new ArrayList<>();

    @Relationship(type = "COVERS", direction = UNDIRECTED)
    private List<NodeType> covers = new ArrayList<>();
}
