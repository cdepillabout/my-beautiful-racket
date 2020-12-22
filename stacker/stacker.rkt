;; #lang racket

#lang br/quicklang

(define (read-syntax path port)
  (define src-lines (port->lines port))
  ;; (define src-datums (format-datums ''(handle ~a) src-lines))
  ;; (define src-datums (format-datums '(handle ~a) src-lines))
  (printf "src-lines: ~v\n" src-lines)
  ;; (define src-datums (format-datums '(handle ~a) src-lines))
  (define src-datums
    (map (λ (x) `(handle ,(read (open-input-string x)))) src-lines))
  (printf "src-datums: ~v\n" src-datums)
  (define module-datum `(module stacker-mod "stacker.rkt"
                          ,@src-datums))
  (datum->syntax #f module-datum))

(provide read-syntax)

;; (define-macro (stacker-module-begin HANDLE-EXPR ...)
;;   (printf "in stacker-module-begin, HANDLE-EXPR: ~v\n" #'(HANDLE-EXPR ...))
;;   #'(#%module-begin
;;      HANDLE-EXPR ...
;;      (display (first stack))
;;      ))

(define-syntax (stacker-module-begin stx)
  ;; (printf "in stacker-module-begin, HANDLE-EXPR: ~v\n" #'(HANDLE-EXPR ...))
  (printf "in stacker-module-begin, stx: ~v\n" stx)
  ;; (syntax-parse stx
  ;;   [(HANDLE-EXPR:x ...)
  ;;    #'(#%module-begin
  ;;       (define (handle [arg #f]) (printf "in handle...\n"))
  ;;       (printf "before running handle expr, ~v...\n" (handle 3))
  ;;       HANDLE-EXPR ...
  ;;       (define hello "hello")
  ;;       (printf "~v ~v\n" (first stack) hello))
  ;;    ]
  (syntax-case stx ()
    [(... HANDLE-EXPR)
     (printf "in syntax-case in stacker-module-begin, HANDLE-EXPR: ~v\n" #'HANDLE-EXPR)
     #'HANDLE-EXPR
     ]
    ;; [else
    ;;  (raise-syntax-error
    ;;   'stacker-module-begin
    ;;   (format "no matching case for calling pattern in: ~a"
    ;;           (syntax->datum stx)))]
    ))

;; (define-macro (mac1 X bar Y)
;;   #'(list X "second" Y))

;; (define-macro-cases mac2
;;   [(mac2 X bar Y) #'(list X "second" Y)])

;; (require (for-syntax syntax/parse))
;; (define-syntax (mac3 caller-stx)
;;   (syntax-parse caller-stx
;;     [((~literal mac3) X (~literal bar) Y) #'(list X "second" Y)]
;;     [else
;;      (raise-syntax-error
;;       'mac3
;;       (format "no matching case for calling pattern in: ~a"
;;               (syntax->datum caller-stx)))]))

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
  ;; (printf "in real handle, arg: ~v\n" arg)
  (cond
    [(number? arg) (push-stack! arg)]
    [(or (equal? * arg) (equal? + arg))
     (define op-result (arg (pop-stack!) (pop-stack!)))
     (push-stack! op-result)]))
