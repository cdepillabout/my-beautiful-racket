#lang br/quicklang

;; (define (read-syntax path port)
;;   (define src-lines (port->lines port))
;;   ;; (datum->syntax #f '(module lucy br 42)))
;;   (datum->syntax #'3 '(module lucy br 42)))
;;   ;; #'(module lucy br 42))

(define (read-syntax path port)
  (define src-lines (port->lines port))
  ;; (define src-datums (format-datums ''(handle ~a) src-lines))
  (define src-datums (format-datums '(handle ~a) src-lines))
  ;; (printf "src-datums: ~v\n" src-datums)
  (define module-datum `(module stacker-mod "stacker.rkt"
                          ,@src-datums))
  (datum->syntax #f module-datum))

(provide read-syntax)
