package com.example.demo.service;

import com.example.demo.model.NodeDomain;
import com.example.demo.repository.NodeDomainRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;

@Service
public class NodeDomainService {

    @Autowired
    NodeDomainRepository nodeDomainRepository;

    public Collection<NodeDomain> findAll() {
        return nodeDomainRepository.findAllNodeDomains();
    }
}
