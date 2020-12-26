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

(define-syntax-rule (swap x y)
  (let ([tmp (+ x x)])
    `(y ,tmp)))

(define-syntax-rule (swap_ x y)
  (let ([tmp x])
    (set! x y)
    (set! y tmp)))


(let ([tmp 5]
      [other 6])
  ;; (let ([tmp tmp])
  ;;   (set! tmp other)
  ;;   (set! other tmp))
  (swap_ tmp other)
  (list tmp other))

(define-syntax (yoyoval stx)
  (syntax-case stx ()
    [yoyoval (identifier? #'yoyoval)
         #'(+ 1 200)]
    ))

(define-syntax self-as-string
  (lambda (stx)
    (datum->syntax stx
                   (format "~s" (syntax->datum stx)))))

(define-syntax (self-as-string_ stx)
  (datum->syntax stx
                 (format "~s" (syntax->datum stx))))

(define-syntax self-as-string__
  (syntax-rules ()
    ;; No way to bind the actual self-as-string identifier when using
    ;; syntax-rules.
    [(_ x ...) (format "~s" (syntax->datum #'(x ...)))]
    )
  )
(define-syntax (self-as-string___ stx)
  (syntax-case stx ()
    ;; No way to bind the actual self-as-string identifier when using
    ;; syntax-rules.
    [(identff x ...) #'(format "~s" (syntax->datum #'(identff x ...)))]
    )
  )

(define example-raw-syntax-case
  (syntax->datum
   (syntax-case #'(+ 1 2) ()
     [(op n1 n2) #'(- n1 n2)])))
