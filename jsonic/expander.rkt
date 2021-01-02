#lang racket
(require json)

(provide #%datum #%app #%top-interaction)

;; (define-macro (jsonic-mb PARSE-TREE)
;;   #'(#%module-begin
;;      (define result-string PARSE-TREE)
;;      (define validated-jsexpr (string->jsexpr result-string))
;;      (display result-string)))

(define-syntax-rule (jsonic-mb parse-tree)
  (#%module-begin
   (define result-string parse-tree)
   (define validated-jsexpr (string->jsexpr result-string))
   (display result-string)))

(provide (rename-out [jsonic-mb #%module-begin]))

;; (define-macro (jsonic-char CHAR-TOK-VALUE)
;;   #'CHAR-TOK-VALUE)
;; (provide jsonic-char)

(define-syntax-rule (jsonic-char char-tok-value)
  char-tok-value)

(provide jsonic-char)

;; (define-macro (jsonic-program SEXP-OR-JSON-STR ...)
;;   #'(string-trim (string-append SEXP-OR-JSON-STR ...)))

(define-syntax-rule (jsonic-program sexp-or-json-str ...)
  (string-trim (string-append sexp-or-json-str ...)))

(provide jsonic-program)

;; (define-macro (jsonic-sexp SEXP-STR)
;;   (with-pattern ([SEXP-DATUM (format-datum '~a #'SEXP-STR)])
;;     #'(jsexpr->string SEXP-DATUM)))

(define-syntax (jsonic-sexp stx)
  (syntax-case stx ()
    [(_ sexp-str)
     ;; (printf "jsonic-sexp, sexp-str: ~v\n" (syntax->datum #'sexp-str))
     (begin
       (define raw-sexp-str (syntax->datum #'sexp-str))
       (define raw-datum (read (open-input-string raw-sexp-str)))
       (with-syntax ([sexp-datum raw-datum])
         #'(jsexpr->string sexp-datum)
         )
       )
     ]))

(provide jsonic-sexp)
