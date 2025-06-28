package com.example.demo.service;

import com.example.demo.model.Editora;
import java.util.List;
import java.util.Optional;

public interface EditoraService {
    Editora salvar(Editora editora);
    List<Editora> listarTodas();
    Optional<Editora> buscarPorId(Long id);
    Editora atualizar(Long id, Editora editoraAtualizada);
    void deletar(Long id);
} 