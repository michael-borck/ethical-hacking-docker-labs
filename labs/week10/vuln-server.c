/*
 * vuln-server.c — intentionally vulnerable login service (Week 10 BOF lab)
 *
 * WHAT IT IS:   A tiny TCP server that asks for a username/password and checks
 *               the password against a hardcoded value. A correct password
 *               unlocks a hidden "secret menu".
 *
 * THE BUG:      The password is copied from the network into a fixed 64-byte
 *               STACK buffer with strcpy(), which performs NO bounds checking.
 *               Send more than 64 bytes and you smash the saved return address
 *               (EIP on x86) — a textbook stack buffer overflow.
 *
 * COMPILE (protections OFF — see docker-compose.yml):
 *   gcc -m32 -fno-stack-protector -z execstack -no-pie -o vuln vuln-server.c
 *      -fno-stack-protector : no stack canary  -> overflow is not detected
 *      -z execstack         : stack is executable -> shellcode runs on the stack
 *      -no-pie              : fixed addresses -> a `jmp esp` gadget stays put
 *      -m32                 : 32-bit x86 -> classic EIP/ESP control, clean addrs
 *
 * AUTHORIZED EDUCATIONAL USE ONLY. Never run this on a system you do not own.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT      4444            /* listens here; host maps 24444 -> 4444      */
#define BUFSIZE   64              /* the overflow target — a small stack buffer */
#define SECRET_PW "letmein123"    /* unlocks the hidden secret menu            */

/*
 * File-scope receive buffers. They live in .bss, NOT on handle_client()'s
 * stack frame. Keeping them off the stack means the ONLY stack buffer in the
 * function is `buf`, so the distance from buf to the saved return address is
 * short and "classic" (~64-80 bytes) — exactly what makes this a clean first
 * buffer-overflow exercise.
 */
static char g_user[64];
static char g_input[2048];

/*
 * Hidden admin path. Reachable two ways:
 *   1) the correct password (the legit route), or
 *   2) a ret2win exploit that overwrites EIP with &secret_menu (the easy-mode
 *      exploit — no shellcode required, just jump here).
 */
void secret_menu(int c) {
    const char *msg =
        "\n[*] SECRET MENU unlocked!\n"
        "    Flag: BOF{w3lc0me_t0_th3_s3cr3t_m3nu}\n"
        "    The real prize, though, is a shell.\n\n";
    send(c, msg, strlen(msg), 0);
}

/* Read one line (up to the first '\n') or maxlen-1 bytes from socket c. */
static ssize_t recv_line(int c, char *dst, size_t maxlen) {
    size_t total = 0;
    while (total < maxlen - 1) {
        ssize_t n = recv(c, dst + total, maxlen - 1 - total, 0);
        if (n <= 0) break;
        total += (size_t)n;
        dst[total] = '\0';
        if (strchr(dst, '\n')) break;       /* stop at end of line */
    }
    dst[strcspn(dst, "\r\n")] = '\0';       /* trim CR/LF */
    return (ssize_t)total;
}

/* Vulnerable per-connection handler (one connection at a time). */
static void handle_client(int c) {
    char buf[BUFSIZE];                 /* <-- the stack buffer we overflow */

    send(c, "BOF-LAB login\nUsername: ", 24, 0);
    recv_line(c, g_user, sizeof(g_user));   /* safe: bounded by sizeof */

    send(c, "Password: ", 10, 0);
    recv_line(c, g_input, sizeof(g_input)); /* recv itself is bounded ... */

    /* ... BUT strcpy() below does NOT check length. Anything past byte 64 of
     * g_input runs off the end of `buf` and overwrites the saved frame pointer
     * and the saved return address on the stack. That is the vulnerability. */
    strcpy(buf, g_input);

    if (strcmp(buf, SECRET_PW) == 0) {
        secret_menu(c);
        send(c, "Access granted.\n", 16, 0);
    } else {
        send(c, "Access denied.\n", 15, 0);
    }
    close(c);
}

int main(void) {
    int s = socket(AF_INET, SOCK_STREAM, 0);
    int on = 1;
    setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family      = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port        = htons(PORT);

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return 1;
    }
    listen(s, 8);
    fprintf(stderr, "[vuln] listening on 0.0.0.0:%d (stack buffer = %d bytes)\n",
            PORT, BUFSIZE);
    fprintf(stderr, "[vuln] protections OFF: no canary, execstack, no-PIE\n");

    /* Single-threaded accept loop: one connection handled per iteration.
     * (A real server would fork/thread — kept simple for clarity.) */
    for (;;) {
        struct sockaddr_in cli;
        socklen_t cl = sizeof(cli);
        int c = accept(s, (struct sockaddr *)&cli, &cl);
        if (c < 0) continue;
        fprintf(stderr, "[vuln] connection from %s:%d\n",
                inet_ntoa(cli.sin_addr), ntohs(cli.sin_port));
        handle_client(c);
    }
    return 0;
}
