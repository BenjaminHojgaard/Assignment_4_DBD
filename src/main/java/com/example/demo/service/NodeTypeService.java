package com.example.demo.service;

import com.example.demo.model.NodeType;
import com.example.demo.repository.NodeDomainRepository;
import com.example.demo.repository.NodeTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;

@Service
public class NodeTypeService {
    @Autowired
    NodeTypeRepository nodeTypeRepository;

    public Collection<NodeType> findAll() {
        return nodeTypeRepository.findAllNodeTypes();
    }
}
