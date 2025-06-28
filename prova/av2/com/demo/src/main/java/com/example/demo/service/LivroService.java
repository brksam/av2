package com.example.demo.service;

import com.example.demo.model.Livro;
import java.util.List;
import java.util.Optional;

public interface LivroService {
    Livro salvar(Livro livro);
    List<Livro> listarTodos();
    Optional<Livro> buscarPorId(Long id);
    Livro atualizar(Long id, Livro livroAtualizado);
    void deletar(Long id);
} 