;; #lang br/quicklang
;; (provide + *)

;; (define-macro (stackerizer-mb EXPR)
;;   #'(#%module-begin
;;      (for-each displayln (reverse (flatten EXPR)))))
;; (provide (rename-out [stackerizer-mb #%module-begin]))

;; (define-macro-cases +
;;   [(+ FIRST) #'FIRST]
;;   [(+ FIRST NEXT ...) #'(list '+ FIRST (+ NEXT ...))])

#lang racket

(require (prefix-in racket: racket))

(provide + *)

(define-syntax (stackerizer-mb stx)
  (printf "stackerizer-mb, stx: ~v\n" stx)
  (syntax-case stx (stackerizer-mb)
    [(stackerizer-mb expr)
     ;; #'(racket:#%module-begin
     (printf "stackerizer-mb, in syntax-case, expr: ~v\n" #'expr)
     #'(racket:#%module-begin (for-each displayln (reverse (flatten expr))))
     ]
    [x
     (printf "stackerizer-mb, in syntax-case, x: ~v\n" #'x)
     #'(racket:#%module-begin #false)
     ]
     ))
(provide
 (rename-out [stackerizer-mb #%module-begin])
 #%app #%datum
 )

;; This is the normal (non macro-in-macro version) of what we're
;; defining.
;; (define-syntax (+ stx)
;;   (syntax-case stx ()
;;     [(+ fst) #'fst]
;;     [(+ fst next ...) #'(list '+ fst (+ next ...))]
;;     ))

;; This is a version that defines each op individually.
;; (define-syntax (define-op stx)
;;   (syntax-case stx ()
;;     [(_ op)
;;      #'(define-syntax (op stxx)
;;          (syntax-case stxx ()
;;            [(_ fst) #'fst]
;;            [(op fst next (... ...))
;;             #'(list 'op fst (op next (... ...)))
;;             ]
;;            )
;;          )
;;      ]))

;; (define-op +)
;; (define-op *)

;; This is a version that defines multiple ops at a time.  Good use of `...`.
(define-syntax (define-ops stx)
  (syntax-case stx ()
    [(_ op ...)
     #'(begin
         (define-syntax (op stxx)
           (syntax-case stxx ()
             [(_ fst) #'fst]
             [(op fst next (... ...))
              #'(list 'op fst (op next (... ...)))
              ]
             )
           )
         ...
         )
     ]))

(define-ops + *)
