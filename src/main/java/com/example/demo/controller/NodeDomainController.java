package com.example.demo.controller;

import com.example.demo.model.NodeDomain;
import com.example.demo.service.NodeDomainService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;

@RestController
@RequestMapping("/nodedomain")
public class NodeDomainController {

    @Autowired
    NodeDomainService nodeDomainService;

    @GetMapping
    public Collection<NodeDomain> getAll() {
        return nodeDomainService.findAll();
    }
}
