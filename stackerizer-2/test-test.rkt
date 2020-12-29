#lang racket

(provide
 what
 (except-out (all-from-out racket) + read-syntax)
 )

(define what read-syntax)
