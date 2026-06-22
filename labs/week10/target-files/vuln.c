/*
 * vuln.c — Deliberately vulnerable network service for Week 10 exploit development.
 *
 * Vulnerability: Stack buffer overflow in handle_client().
 *   - buf is 64 bytes; read() accepts up to 256 bytes — no bounds check.
 *   - Compiled WITHOUT stack canaries (-fno-stack-protector)
 *   - Compiled WITHOUT PIE (-no-pie) — fixed base address, easier RIP control
 *   - Stack executable (-z execstack) — shellcode injection is possible
 *
 * DO NOT deploy this outside the lab environment.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>

#define PORT 9999
#define BUF_SIZE 64
#define READ_SIZE 256

void secret_function() {
    /* This function is never called normally — can you redirect execution here? */
    printf("*** You reached secret_function! ***\n");
    fflush(stdout);
    system("/bin/sh");
}

void handle_client(int sock) {
    char buf[BUF_SIZE];   /* 64-byte buffer */
    char response[128];

    write(sock, "Welcome to CyberCorp Debug Service v0.1\n", 40);
    write(sock, "Enter your name: ", 17);

    /* BUG: reads READ_SIZE (256) bytes into a BUF_SIZE (64) byte buffer */
    int n = read(sock, buf, READ_SIZE);
    if (n < 0) return;

    /* Strip newline if present */
    if (n > 0 && buf[n-1] == '\n') buf[n-1] = '\0';

    snprintf(response, sizeof(response), "Hello, %s!\n", buf);
    write(sock, response, strlen(response));
}

int main() {
    int server_fd, client_fd;
    struct sockaddr_in addr;
    int opt = 1;

    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(PORT);

    bind(server_fd, (struct sockaddr *)&addr, sizeof(addr));
    listen(server_fd, 5);

    printf("Vuln service listening on port %d\n", PORT);
    printf("secret_function() is at: %p\n", (void *)secret_function);
    fflush(stdout);

    while (1) {
        socklen_t len = sizeof(addr);
        client_fd = accept(server_fd, (struct sockaddr *)&addr, &len);
        if (client_fd < 0) continue;
        handle_client(client_fd);
        close(client_fd);
    }
    return 0;
}
