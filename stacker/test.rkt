#lang br

(begin
  (define x 100)
  )

(define-macro (nonplussed OUTER-+)
  #'(begin
      (define + -)
      (list (+ 21 21) (OUTER-+ 21 21))))
(expand-once #'(nonplussed +))

(define-macro (rev ARGS)
  (printf "rev: ARGS: ~v\n" (syntax ARGS))
  (define arg-stxs (syntax->list #'ARGS))
  ;; (with-pattern ([(REVERSED-ARG ...) (reverse arg-stxs)])
  ;;   #'(list REVERSED-ARG ...)))
  (with-syntax ([(REVERSED-ARG ...) (reverse arg-stxs)])
    #'(list REVERSED-ARG ...)))
(rev (10 20 30))


(require syntax/to-string)

;; (define-macro (m foo) #'"match")
;; (m foo) ; "match"
;; (m bar) 

;; (define-syntax-rule (m foo) "match")

(define-syntax m
  (syntax-rules (foo)
    [(m foo) (quote foo)]
    [(m foo x ...) (quote (x ...))]))

(require racket/syntax)

(define-syntax (haha stx)
  (syntax-case stx (foo)
    [(_ foo) #''foo]
    [(_ foo arg) #'arg]
    [(_ bar ...) #'(quote (bar ...))]
    ))

;; (define-macro (m3 MID ... LAST)
;;   (with-pattern ([(ONE TWO THREE) (syntax LAST)]
;;                  [(ARG ...) #'(MID ...)])
;;     #'(list ARG ... THREE TWO ONE)))

;; (m3 25 42 ("foo" "bar" "zam"))

(define-syntax (m3 stx)
  (syntax-case stx ()
    [(_ 25 "hello" mid ... lst)
     (with-syntax ([(one two three) #'lst])
       #'(list mid ... three two one))]))
