package com.example.demo.service;

import com.example.demo.model.Role;
import com.example.demo.model.Usuario;
import com.example.demo.repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class AuthServiceTest {
    @Mock
    private UsuarioRepository usuarioRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthService authService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testRegisterSuccess() {
        when(usuarioRepository.findByUsername("user")).thenReturn(Optional.empty());
        when(passwordEncoder.encode("senha")).thenReturn("senha-criptografada");
        when(usuarioRepository.save(any(Usuario.class))).thenAnswer(i -> i.getArgument(0));

        Usuario usuario = authService.register("user", "senha", Role.USER);
        assertEquals("user", usuario.getUsername());
        assertEquals("senha-criptografada", usuario.getPassword());
        assertEquals(Role.USER, usuario.getRole());
    }

    @Test
    void testRegisterUserAlreadyExists() {
        when(usuarioRepository.findByUsername("user")).thenReturn(Optional.of(new Usuario()));
        assertThrows(RuntimeException.class, () -> authService.register("user", "senha", Role.USER));
    }

    @Test
    void testLoginSuccess() {
        Usuario usuario = Usuario.builder().username("user").password("senha-criptografada").role(Role.USER).build();
        when(usuarioRepository.findByUsername("user")).thenReturn(Optional.of(usuario));
        when(passwordEncoder.matches("senha", "senha-criptografada")).thenReturn(true);
        when(jwtService.generateToken(eq("user"), eq("USER"))).thenReturn("jwt-token");

        String token = authService.login("user", "senha");
        assertEquals("jwt-token", token);
    }

    @Test
    void testLoginUserNotFound() {
        when(usuarioRepository.findByUsername("user")).thenReturn(Optional.empty());
        assertThrows(RuntimeException.class, () -> authService.login("user", "senha"));
    }

    @Test
    void testLoginInvalidPassword() {
        Usuario usuario = Usuario.builder().username("user").password("senha-criptografada").role(Role.USER).build();
        when(usuarioRepository.findByUsername("user")).thenReturn(Optional.of(usuario));
        when(passwordEncoder.matches("senha", "senha-criptografada")).thenReturn(false);
        assertThrows(RuntimeException.class, () -> authService.login("user", "senha"));
    }
} 