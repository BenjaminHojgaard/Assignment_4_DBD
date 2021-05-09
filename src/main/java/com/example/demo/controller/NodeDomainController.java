package com.example.demo.controller;

import com.example.demo.model.NodeDomain;
import com.example.demo.model.NodeType;
import com.example.demo.service.NodeDomainService;
import com.example.demo.service.NodeTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;

@RestController
@RequestMapping("/nodedomain")
public class NodeDomainController {

    @Autowired
    NodeDomainService nodeDomainService;

    @GetMapping
    public Collection<NodeDomain> shortestPath(@RequestParam String typeName, @RequestParam String domainName){
        return nodeDomainService.shortestPath(typeName, domainName);
    }
}
