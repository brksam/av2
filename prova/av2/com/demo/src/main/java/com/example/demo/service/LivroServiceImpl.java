package com.example.demo.service;

import com.example.demo.model.Livro;
import com.example.demo.repository.LivroRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LivroServiceImpl implements LivroService {
    private final LivroRepository livroRepository;

    @Override
    public Livro salvar(Livro livro) {
        return livroRepository.save(livro);
    }

    @Override
    public List<Livro> listarTodos() {
        return livroRepository.findAll();
    }

    @Override
    public Optional<Livro> buscarPorId(Long id) {
        return livroRepository.findById(id);
    }

    @Override
    public Livro atualizar(Long id, Livro livroAtualizado) {
        return livroRepository.findById(id)
                .map(livro -> {
                    livro.setTitulo(livroAtualizado.getTitulo());
                    livro.setAutor(livroAtualizado.getAutor());
                    livro.setPreco(livroAtualizado.getPreco());
                    livro.setEditora(livroAtualizado.getEditora());
                    return livroRepository.save(livro);
                })
                .orElseThrow(() -> new RuntimeException("Livro não encontrado"));
    }

    @Override
    public void deletar(Long id) {
        livroRepository.deleteById(id);
    }
} 