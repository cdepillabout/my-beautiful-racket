
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

(define-syntax-rule (handle expr1 fallback)
  (with-handlers ([exn:fail? (λ (e) fallback)]) expr1))

(module+ test
  (check-equal? (handle 5 6) 5)
  (check-equal? (handle (/ 1 0) 'whoops) 'whoops)
  )

(define-syntax-rule (handle_ expr1 fallback)
  (handle-helper (λ()expr1) (λ()fallback)))

(define (handle-helper expr1-thunk fallback-thunk)
  (with-handlers ([exn:fail? (λ (e) (fallback-thunk))]) (expr1-thunk)))

(module+ test
  (check-equal? (handle_ 5 6) 5)
  (check-equal? (handle_ (/ 1 0) 'whoops) 'whoops)
  )

;; (define-syntax-rule (andlet1 var e1 e2)
;;   (let ([var e1])
;;     (if var e2 #f)))

(define-syntax-rule (andlet1 var e1 e2)
  (andlet1-helper e1 (λ(var)e2)))

(define (andlet1-helper e1 e2-thunk)
  (let ([xxx e1])
    (if xxx (e2-thunk xxx) #f)))

(module+ test
  (check-equal? (andlet1 x 5 (+ x 100)) 105)
  (check-equal? (andlet1 x (< 100 2) (if x "yes" "no")) #f)
  (check-equal? (andlet1 x (< 2 100) (if x "yes" "no")) "yes")
  )

(define-syntax-rule (my-and expr ...)
  (my-and-helper (λ()expr) ...))

(define (my-and-helper . args)
  (match args
    [(cons head rst)
     (if (head) (apply my-and-helper rst) #f)]
    [_ #t]))

(module+ test
  (check-equal? (my-and (+ 1 4) #t (> 100 2)) #t)
  (check-equal? (my-and (+ 1 4) #f (/ 1 0)) #f)
  )

(define-syntax-rule (my-cond-v0 [question-expr answer-expr] ...)
  (my-cond-v0-helper (list (λ()question-expr) (λ()answer-expr)) ...)
  )

;; (define (my-cond-v0-helper . args)
;;   (match args
;;     [(cons (list head-question head-answer) rst)
;;      (if (head-question)
;;          (head-answer)
;;          (apply my-cond-v0-helper rst)
;;         (define (my-cond-v0-helper . args)
;;  )]))

(define/match (my-cond-v0-helper . args)
  [((cons (list head-question head-answer) rst))
   (if (head-question) (head-answer) (apply my-cond-v0-helper rst)
       )])

(module+ test
  (check-equal? (my-cond-v0 [(> 100 2) "hello"] [#f (/ 1 0)]) "hello")
  (check-equal? (my-cond-v0 [#f (/ 1 0)] [(> 100 2) "hello"]) "hello")
  )

;; (define/match-let (my-func (list a b))
;;   (list a b a b))

;; (define-syntax (define/match-let stx)
;;   (syntax-case stx ()
;;     [(_ (func-name args ...) body)
;;      #'(define/match (func-name func-args)
;;          [args
;;   (define/match (

(define-syntax my-and-v2
  (syntax-rules ()
    [(my-and-v2 expr1 expr ...)
     (if expr1 (my-and-v2 expr ...) #f)
     ]
    [(my-and-v2) #t]))

(module+ test
  (check-equal? (my-and-v2 (+ 1 4) #t (> 100 2)) #t)
  (check-equal? (my-and-v2 (+ 1 4) #f (/ 1 0)) #f)
  )

(define-syntax my-cond
  (syntax-rules (else =>)
    [(my-cond)
     (void)]
    [(my-cond [else answer-expr])
     answer-expr]
    [(my-cond [question-expr => proc-expr] clause ...)
     (let ([x question-expr])
       (if x (proc-expr x) (my-cond clause ...)))
     ]
    [(my-cond [question-expr answer-expr1 answer-expr ...] clause ...)
     (if question-expr
         (begin answer-expr1 answer-expr ...)
         (my-cond clause ...))]
    [(my-cond [question-expr] clause ...)
     (let ([x question-expr])
       (if x x (my-cond clause ...)))]
    ))

(module+ test
  (check-equal? (void)
                (my-cond))
  (check-equal?
   "bye"
   (my-cond [#f "hello"] [else "bye"])
   )
  (check-equal?
   #t
   (my-cond [(+ 1 3) => (λ(x)(> x 2))] [else "bye"])
   )
  (check-equal?
   '(3 100)
   (let ([x 0])
     (list (my-cond [#t (set! x 100) 3]) x))
   )
  )

(require (for-syntax syntax/parse))

(define-syntax andlet2
  (lambda (stx)
    (syntax-parse stx
      ;; [(_ var e1 e2)
      ;;  #:declare var identifier
      ;; [(_ (~var var identifier) e1 e2)
      [(_ var:id e1:expr e2:expr)
       #'(let ([var e1])
           (if var e2 #f))
       ]
      )))

(module+ test
  (check-equal?
   8
   (andlet2 x (+ 1 3) (+ x 4))
   )
  (check-equal?
   #f
   (andlet2 x #f (/ 1 0))
   )
  )

;; (define-syntax (iflet2 var test ifbody elsebody)
;;   (let ([xxx test])
;;     (if xxx
;;         (let ([var xxx]) ifbody)
;;         elsebody
;;         )))

(define-syntax (iflet2 stx)
  (syntax-parse stx
    [(_ var:id test:expr ifbody:expr elsebody:expr)
     #'(let ([xxx test])
         (if xxx
             (let ([var xxx]) ifbody)
             elsebody
             ))
     ]
    ))

(module+ test
  (define alist2 '((1 . apple) (2 . pear)))
  (check-equal? (iflet2 x (assoc 1 alist2) (cdr x) 'none) 'apple)
  (check-equal? (let ([x 'plum]) (iflet2 x (assoc 3 alist2) (cdr x) x)) 'plum)
  )
