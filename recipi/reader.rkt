#lang racket
(require "tokenizer.rkt" "parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (printf "parse tree: ~v\n" parse-tree)
  (define module-datum `(module jsonic-module jsonic/expander
                          ,parse-tree))
  (datum->syntax #f module-datum))
(provide read-syntax)
