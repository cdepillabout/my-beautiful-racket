;; #lang s-exp "raquet-mlang.rkt"
#lang reader "raquet.rkt"

(define identity (function (x) x))
(provide identity)

(printf "in raquet-example.rkt, use (identity 3): ~a\n" (identity 3))
