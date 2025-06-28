package com.example.demo.controller;

import com.example.demo.model.Editora;
import com.example.demo.service.EditoraService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@RestController
@RequestMapping("/editoras")
@RequiredArgsConstructor
public class EditoraController {

    private final EditoraService editoraService;

    @GetMapping
    public List<Editora> listarTodas() {
        return editoraService.listarTodas();
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping
    public Editora criar(@RequestBody Editora editora) {
        return editoraService.salvar(editora);
    }

    @PreAuthorize("isAuthenticated()")
    @PutMapping("/{id}")
    public Editora atualizar(@PathVariable Long id, @RequestBody Editora editoraAtualizada) {
        return editoraService.atualizar(id, editoraAtualizada);
    }

    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/{id}")
    public void deletar(@PathVariable Long id) {
        editoraService.deletar(id);
    }
}
