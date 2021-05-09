package com.example.demo.controller;

import com.example.demo.model.NodeType;
import com.example.demo.service.NodeTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;

@RestController
@RequestMapping("/nodetype")
public class NodeTypeController {
    @Autowired
    private NodeTypeService nodeTypeService;

    @GetMapping
    public Collection<NodeType> getAll(){
        return nodeTypeService.findAll();
    }
}
