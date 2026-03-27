---
paths:
  - "**/*.java"
---

# Backend Conventions — Java 21 + Spring Boot

## Layered Architecture

`Controller → Service → Repository`

Dependencies flow downward only. Each layer has one job.

| Layer | Responsibility | Never |
|---|---|---|
| **Controller** | Validate input, delegate to service, return response | Business logic, repo calls, `@Transactional` |
| **Service** | All business logic and orchestration. `@Transactional` on write methods | Return JPA entities, throw `ResponseStatusException` |
| **Repository** | CRUD + JPQL/native queries | Business logic, mapping |

Controllers max ~5 lines per method:

```java
// Good
@GetMapping("/{id}")
public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
    return ResponseEntity.ok(userService.getById(id));
}

// Bad — business logic in controller
@GetMapping("/{id}")
public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
    User user = userRepository.findById(id).orElseThrow();
    if (!user.isActive()) throw new ResponseStatusException(HttpStatus.FORBIDDEN);
    return ResponseEntity.ok(new UserDto(user.getId(), user.getName()));
}
```

## Lombok — MANDATORY

- `@RequiredArgsConstructor` for constructor injection (+ `private final` fields)
- `@Getter @Setter` on entities and config properties
- `@NoArgsConstructor` on JPA entities
- `@Slf4j` for logging — never `LoggerFactory.getLogger()`
- `@Builder` for objects with 3+ fields
- Never `@Autowired` field injection

```java
// Good
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
}

// Bad
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
}
```

## Java 21 Patterns

**Records for read-only DTOs:**
```java
public record UserDto(Long id, String name, String email) {}
```

**Text blocks** for multi-line strings:
```java
String query = """
    SELECT u FROM User u
    WHERE u.active = true
    ORDER BY u.name
    """;
```

**Pattern matching** for instanceof:
```java
// Good
if (event instanceof OrderPlaced placed) {
    process(placed.orderId());
}
// Bad
if (event instanceof OrderPlaced) {
    process(((OrderPlaced) event).orderId());
}
```

## Code Style

- Guard clauses / early returns — max 2 nesting levels
- Methods ≤ ~30 lines
- Services ≤ ~250 lines — split by responsibility if larger
- `private static final` for constants
- Stream API for collections
- `ResponseEntity.ok()`, `.created()`, `.noContent()` — never `new ResponseEntity<>()`
- `@ConfigurationProperties` for all app properties — never `@Value` for app config

## JPA Entities

```java
@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;
}
```

- Keep entities as data holders — no business logic
- Use `@Column(nullable = false)` to mirror DB constraints
- Prefer `Optional<T>` from repository methods, don't `.get()` without check
