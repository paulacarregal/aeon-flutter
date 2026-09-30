package com.aeon.backend.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.ListUsersPage;
import com.google.firebase.auth.UserRecord;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public ResponseEntity<?> getUsers() {

        try {
            List<Map<String, Object>> users = new ArrayList<>();

            ListUsersPage page =
                    FirebaseAuth.getInstance().listUsers(null);

            for (UserRecord user : page.iterateAll()) {

                users.add(Map.of(
                        "uid", user.getUid(),
                        "email", user.getEmail() != null ? user.getEmail() : "",
                        "displayName",
                        user.getDisplayName() != null
                                ? user.getDisplayName()
                                : "",
                        "disabled", user.isDisabled()
                ));
            }

            return ResponseEntity.ok(users);

        } catch (Exception e) {

            return ResponseEntity.internalServerError()
                    .body(Map.of(
                            "error",
                            "Erro ao consultar usuários do Firebase."
                    ));
        }
    }
}