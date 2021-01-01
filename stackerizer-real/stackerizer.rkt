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

;; Use syntax-case to define a macro.
;; (define-syntax (stackerizer-mb stx)
;;   (printf "stackerizer-mb, stx: ~v\n" stx)
;;   (syntax-case stx (stackerizer-mb)
;;     [(stackerizer-mb expr)
;;      ;; #'(racket:#%module-begin
;;      (printf "stackerizer-mb, in syntax-case, expr: ~v\n" #'expr)
;;      #'(racket:#%module-begin (for-each displayln (reverse (flatten expr))))
;;      ]
;;     ;; This shouldn't get run unless there is some big problem.
;;     [x
;;      (printf "stackerizer-mb, in syntax-case, x: ~v\n" #'x)
;;      #'(racket:#%module-begin #false)
;;      ]
;;      ))

;; Use define-syntax-rule to define a macro.
(define-syntax-rule (stackerizer-mb expr)
  (racket:#%module-begin (for-each displayln (reverse (flatten expr)))))

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
;; This uses syntax-case.
;; (define-syntax (define-ops stx)
;;   (syntax-case stx ()
;;     [(_ op ...)
;;      #'(begin
;;          (define-syntax (op stxx)
;;            (syntax-case stxx ()
;;              [(_ fst) #'fst]
;;              [(op fst next (... ...))
;;               #'(list 'op fst (op next (... ...)))
;;               ]
;;              )
;;            )
;;          ...
;;          )
;;      ]))

;; Just like above, but use define-syntax-rule.
(define-syntax-rule (define-ops op ...)
  (begin
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
  )

(define-ops + *)
