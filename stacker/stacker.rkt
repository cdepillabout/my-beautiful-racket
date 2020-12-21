#lang br/quicklang

(define (read-syntax path port)
  (define src-lines (port->lines port))
  ;; (datum->syntax #f '(module lucy br 42)))
  (datum->syntax #'3 '(module lucy br 42)))
  ;; #'(module lucy br 42))

(provide read-syntax)
