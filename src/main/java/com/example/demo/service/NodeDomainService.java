package com.example.demo.service;

import com.example.demo.model.NodeDomain;
import com.example.demo.model.NodeType;
import com.example.demo.repository.NodeDomainRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;

@Service
public class NodeDomainService {

    @Autowired
    private NodeDomainRepository nodeDomainRepository;

    public Collection<NodeDomain> shortestPath(String typeName, String domainName){
        return nodeDomainRepository.shortestPath(typeName, domainName);
    }
}
