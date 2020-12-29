#lang racket

(require
 (prefix-in racket: racket)
 (for-template (only-in "../stackerizer/stackerizer.rkt" convert-expr))
 )

(provide
 (except-out (all-from-out racket) #%module-begin read-syntax read)
 (rename-out [my-read-syntax read-syntax])
 )

(define (my-read-syntax path port)
  ;; (define src-lines (port->lines port))
  ;; (define src-datums (format-datums ''(handle ~a) src-lines))
  ;; (define src-datums (format-datums '(handle ~a) src-lines))
  ;; (printf "src-lines: ~v\n" src-lines)
  (define racket-parsed-syntax (racket:read-syntax path port))
  (printf "racket-parsed-syntax: ~v\n" racket-parsed-syntax)
  (define converted-stx (convert-expr racket-parsed-syntax))
  (printf "converted-stx: ~v\n" converted-stx)
  (define converted-stx-lst (syntax->datum converted-stx))
  (printf "converted-stx-lst: ~v\n" converted-stx-lst)
  (define (add-handle x) `(handle ,x))
  (define with-handles (map add-handle converted-stx-lst))
  (printf "with-handles: ~v\n" with-handles)
  ;; (define module-datum `(module stacker-mod "my-stacker.rkt"
  ;;                         ,@src-datums))
  ;; (datum->syntax #f module-datum))
  #`(module stacker-mod "../stacker/my-stacker.rkt"
      #,@with-handles)
  )
