#lang racket
(require brag/support)

(define (make-tokenizer port)
  (-> port? (-> lexer-res/c))
  (define/contract (next-token) (-> lexer-res/c)
    (jsonic-lexer port next-token))
  next-token)
(provide make-tokenizer)

(define lexer-res/c (or/c token-struct? eof-object?))

(define/contract (jsonic-lexer port cont)
  (-> port? (-> lexer-res/c) lexer-res/c)
  (define/contract lexer-func
    (-> port? lexer-res/c)
    (lexer
     ;; This doesn't match a "//" that doesn't have a trailing newline.
     [(from/to "//" "\n") (cont)]
     ;; This incorrectly matches a $@ that is used in a sexp.
     [(from/to "@$" "$@")
      (token 'SEXP-TOK (trim-ends "@$" lexeme "$@"))]
     [any-char (token 'CHAR-TOK lexeme)]))
  (lexer-func port))
