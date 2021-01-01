
#lang racket

(module+ test
  (require rackunit)
  )

(define-syntax (my-assert stx)
  (syntax-case stx ()
    [(_ expr)
     #'(unless expr
         (error 'assert "assertion failed: ~s" (quote expr)))
     ]))

(define-syntax-rule (my-assert2 expr)
  (unless expr
    (error 'assert "assertion failed: ~s" (quote expr)))
  )

(define-syntax-rule (noisy-v1 expr)
  (begin
    (printf "evaluating ~v...\n" 'expr)
    expr
    ))

(define-syntax-rule (iflet var test ifbody elsebody)
  (let ([xxx test])
    (if xxx
        (let ([var xxx]) ifbody)
        elsebody
        )))

(module+ test
  (define alist '((1 . apple) (2 . pear)))
  (check-equal? (iflet x (assoc 1 alist) (cdr x) 'none) 'apple)
  (check-equal? (let ([x 'plum]) (iflet x (assoc 3 alist) (cdr x) x)) 'plum)
  )

(define-syntax-rule (forever expr)
  (let loop ()
    expr
    (loop)))
