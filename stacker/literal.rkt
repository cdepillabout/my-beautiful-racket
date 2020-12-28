#lang racket
(require syntax/strip-context)

(provide (rename-out [literal-read read]
                     [literal-read-syntax read-syntax]))

(define (literal-read in)
  (syntax->datum
   (literal-read-syntax #f in)))

(define (literal-read-syntax src in)
  (with-syntax ([str (port->string in)])
    ;; I don't know why this strip-context is required.
    ;; (strip-context
     #`(module anything racket
         (provide data)
         ;; A non-quoted string.
         (define data str)
         ;; (define data 'str)

         ;; A doubly-quoted string.
         ;; (define data ''str)

         ;; Use a literal (quote str), which works even though str is
         ;; bound by with-syntax.
         ;; (define data (unsyntax (datum->syntax #f ''str)))
         ;; (define data #,(datum->syntax #f ''str))
         )
     ;; )
    ))
