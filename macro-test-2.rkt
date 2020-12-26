
#lang racket/base

(require (for-syntax racket/base))

(define-syntax (swap stx)
  (syntax-case stx ()
    [(swap x y) (begin
                  (check-ids stx #'(x y))
                  #'(let ([tmp x])
                      (set! x y)
                      (set! y tmp)))]))

(begin-for-syntax
  (define (check-ids stx forms)
    (for-each
     (λ (form)
       (unless (identifier? form)
         (raise-syntax-error #f "not an identifier" stx form)))
     (syntax->list forms))))

;; (define-syntax (rotate stx)
;;   (syntax-case stx ()
;;     [(rotate a c ...)
;;      (begin
;;        (check-ids stx #'(a c ...))
;;        #'(shift-to (c ... a) (a c ...)))]))

(module a racket
  (define button 0)
  (provide (for-syntax see-button))
  ; Why not (define see-button #'button)? We explain later.
  (define-for-syntax see-button #'button)
  )

(module b racket
  (require (submod ".." a))
  (define button 8)
  (define-syntax (m stx)
    ;; (printf "is ident? ~a\n" (identifier? see-button))
    see-button)
  (m))

(module c racket
  (define x 0) ; defined at phase level 0
  (provide x))
(module d racket
  ;; (require (for-syntax (submod ".." c)))
  (require (submod ".." c))
  ; has a binding at phase level 1, not 0:
  ;; (define-syntax blah #'x)
  (define-syntax (blah stx) #'x)
  )

;; (expand #'(module hello racket (+ 1 3)))
;;
;; becomes:
;;
;; (module hello racket
;;   (#%module-begin
;;    (module configure-runtime (quote #%kernel)
;;      (#%module-begin
;;       (#%require racket/runtime-config)
;;       (#%app configure (quote #f))
;;       )
;;      )
;;    (#%app call-with-values
;;           (lambda () (#%app + (quote 1) (quote 3)))
;;           print-values)
;;    )
;;   )
