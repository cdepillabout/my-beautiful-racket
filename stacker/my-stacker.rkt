
#lang racket

(define (read-syntax path port)
  (define src-lines (port->lines port))
  ;; (define src-datums (format-datums ''(handle ~a) src-lines))
  ;; (define src-datums (format-datums '(handle ~a) src-lines))
  ;; (printf "src-lines: ~v\n" src-lines)
  (define src-datums
    (map (λ (x) `(handle ,(read (open-input-string x)))) src-lines))
  ;; (printf "src-datums: ~v\n" src-datums)
  (define module-datum `(module stacker-mod "my-stacker.rkt"
                          ,@src-datums))
  (datum->syntax #f module-datum))

(provide read-syntax)

(define-syntax (stacker-module-begin stx)
  (printf "in stacker-module-begin, stx: ~v\n" stx)
  (syntax-case stx ()
    [(_ handle-expr ...)
     #'(#%module-begin
        handle-expr ...
        (display (first stack))
        )
     ]))

(provide
 (rename-out [stacker-module-begin #%module-begin])
 handle * + #%app #%datum #%top-interaction)

(define stack empty)

(define (pop-stack!)
  (define arg (first stack))
  (set! stack (rest stack))
  arg)

(define (push-stack! arg)
  (set! stack (cons arg stack)))

(define (handle [arg #f])
  ;; (printf "in real handle, arg: ~v\n" arg)
  (cond
    [(number? arg) (push-stack! arg)]
    [(or (equal? * arg) (equal? + arg))
     (define op-result (arg (pop-stack!) (pop-stack!)))
     (push-stack! op-result)]
    [else (void)]
    ))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Two ways to turn a symbol ('+) back into a procedure ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; Pass a lexical context to datum->syntax.
;; ((eval (datum->syntax #'true '+)) 3 4)

;; ;; Define a namespace anchor to give to eval.
;; (define-namespace-anchor my-namespace-anchor)

;; (let ([f
;;        (parameterize
;;            ([current-namespace (namespace-anchor->namespace my-namespace-anchor)])
;;          (eval (datum->syntax #false '+)))]
;;       )
;;   (f 30 40)
;;   )
