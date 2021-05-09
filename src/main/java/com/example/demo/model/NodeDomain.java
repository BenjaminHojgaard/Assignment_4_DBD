package com.example.demo.model;

import lombok.Data;
import org.neo4j.ogm.annotation.NodeEntity;
import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;

@NodeEntity
@Data
public class NodeDomain {

    @Id
    @GeneratedValue
    Long Id;

    String name, description;

}
