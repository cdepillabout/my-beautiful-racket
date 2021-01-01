#lang racket

;; (define-macro (bf-module-begin PARSE-TREE)
;;   #'(#%module-begin
;;      'PARSE-TREE))
;; (provide (rename-out [bf-module-begin #%module-begin]))

(define-syntax (bf-module-begin stx)
  (syntax-case stx ()
    [(_ parse-tree)
     #'(#%module-begin
        parse-tree)]
    ))
(provide
 (rename-out [bf-module-begin #%module-begin])
 #%top-interaction)

;; (define-macro (bf-program OP-OR-LOOP-ARG ...)
;;   #'(void OP-OR-LOOP-ARG ...))

(define-syntax-rule (bf-program op-or-loop-arg ...)
  (void op-or-loop-arg ...))
(provide bf-program)

;; (define-macro (bf-loop "[" OP-OR-LOOP-ARG ... "]")
;;   #'(until (zero? (current-byte))
;;       OP-OR-LOOP-ARG ...))

(define-syntax (bf-loop stx)
  (syntax-case stx ()
    [(_ "[" op-or-loop-arg ... "]")
     #'(until (zero? (current-byte))
              op-or-loop-arg ...)
     ]
    ))
(provide bf-loop)

;; (define-macro-cases bf-op
;;   [(bf-op ">") #'(gt)]
;;   [(bf-op "<") #'(lt)]
;;   [(bf-op "+") #'(plus)]
;;   [(bf-op "-") #'(minus)]
;;   [(bf-op ".") #'(period)]
;;   [(bf-op ",") #'(comma)])

(define-syntax (bf-op stx)
  (syntax-case stx ()
    [(_ ">") #'(gt)]
    [(_ "<") #'(lt)]
    [(_ "+") #'(plus)]
    [(_ "-") #'(minus)]
    [(_ ".") #'(period)]
    [(_ ",") #'(comma)]
    ))

(provide bf-op)

(define-syntax (until stx)
  (syntax-case stx ()
    [(_ test body ...)
     ;; ;; This doesn't work because you can't have recursive macros.
     ;; #'(if test
     ;;       (void)
     ;;       ((lambda () (until test body ...)))
     ;;       )

     ;; ;; This works, using for to loop.
     ;; #'(for ([_ (in-naturals)]
     ;;         #:break test)
     ;;     body ...
     ;;     )

     ;; This also works, using a let-based loop.
     #'(let loop ()
         (if test
             (void)
             (begin
               body ...
               (loop))))
     ]
    ))

(define-syntax (until_ stx)

  ;; A helper function that uses lambdas to defer running stuff.
  (define (until_helper test-func body-func)
    (if (test-func)
        (void)
        (begin
          (body-func)
          (until_helper test-func body-func))))

  (syntax-case stx ()
    [(_ test body ...)
     ;; Use a helper function with lambdas to defer stuff from running.
     ;; #`(#,until_helper (lambda () test) (lambda () body ...))

     ;; This also works:
     (with-syntax ([until_helper until_helper])
       #`(until_helper (lambda () test) (lambda () body ...))
       )
     ]
    ))

(define-syntax (my-example stx)
  (define my-val 3)
  (syntax-case stx ()
    [(_ expr ...)
     #`#,my-val
     ]
    ))


(define arr (make-vector 30000 0))
(define ptr 0)

(define (current-byte) (vector-ref arr ptr))
(define (set-current-byte! val) (vector-set! arr ptr val))

(define (gt) (set! ptr (add1 ptr)))
(define (lt) (set! ptr (sub1 ptr)))
(define (plus) (set-current-byte! (add1 (current-byte))))
(define (minus) (set-current-byte! (sub1 (current-byte))))
(define (period) (write-byte (current-byte)))
(define (comma) (set-current-byte! (read-byte)))
