package com.example.demo.service;

import com.example.demo.model.Editora;
import com.example.demo.repository.EditoraRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EditoraServiceImpl implements EditoraService {
    private final EditoraRepository editoraRepository;

    @Override
    public Editora salvar(Editora editora) {
        return editoraRepository.save(editora);
    }

    @Override
    public List<Editora> listarTodas() {
        return editoraRepository.findAll();
    }

    @Override
    public Optional<Editora> buscarPorId(Long id) {
        return editoraRepository.findById(id);
    }

    @Override
    public Editora atualizar(Long id, Editora editoraAtualizada) {
        return editoraRepository.findById(id)
                .map(editora -> {
                    editora.setNome(editoraAtualizada.getNome());
                    editora.setPais(editoraAtualizada.getPais());
                    return editoraRepository.save(editora);
                })
                .orElseThrow(() -> new RuntimeException("Editora não encontrada"));
    }

    @Override
    public void deletar(Long id) {
        editoraRepository.deleteById(id);
    }
} 