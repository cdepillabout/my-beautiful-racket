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

(define-macro (stacker-module-begin HANDLE-EXPR ...)
  ;; (printf "in stacker-module-begin, HANDLE-EXPR: ~v\n" #'(HANDLE-EXPR ...))
  #'(#%module-begin
     (define (handle [arg #f]) (printf "in handle...\n"))
     (printf "before running handle expr, ~v...\n" (handle 3))
     HANDLE-EXPR ...
     (define hello "hello")
     (printf "~v ~v\n" (first stack) hello)))

(provide (rename-out [stacker-module-begin #%module-begin]) handle * +)

(define stack empty)

(define (pop-stack!)
  (define arg (first stack))
  (set! stack (rest stack))
  arg)

(define (push-stack! arg)
  (set! stack (cons arg stack)))

;; (define handle
;;   (case-lambda
;;     [() (printf "GOT NOTHING\n")]
;;     [(x) (printf "GOT SOMETHING: ~v\n" x)]))

(define (handle [arg #f])
  (cond
    [(number? arg) (push-stack! arg)]
    [(or (equal? * arg) (equal? + arg))
     (define op-result (arg (pop-stack!) (pop-stack!)))
     (push-stack! op-result)]))
