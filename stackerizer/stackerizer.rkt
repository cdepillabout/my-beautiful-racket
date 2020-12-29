#lang racket

(provide (except-out (all-from-out racket)
                     #%module-begin)
         (rename-out [my-module-begin #%module-begin])
         )

;; (define-syntax-rule (module-begin expr ...)
;;   (#%module-begin
;;    (define page `(html expr ...))
;;    (provide page)))

(begin-for-syntax
  (define (convert-expr stx)
    ;; (printf "convert-expr, stx: ~a\n" stx)
    (syntax-case stx ()
      [(op nums ...)
       (begin
         ;; (define whatwhat (map convert-expr (syntax->list #'(nums ...))))
         (define whatwhat (map convert-expr (syntax-e #'(nums ...))))
         ;; (printf "convert-expr, whatwhat: ~a\n" whatwhat)
         (define whowho
           (for/fold
               ([res '()])
               ([i whatwhat])
             (cond
               [(pair? (syntax->list i)) (append (syntax->list i) res)]
               [else (cons i res)])))
         ;; (printf "convert-expr, whowho: ~a\n" whowho)
         (quasisyntax (#,@whowho op))
         )
       ]
      [num
       #'num
       ]
      )
    )
  )

;; 4 8 + 3 *

(define-syntax (my-module-begin stx)
  (printf "my-module-begin, stx: ~a\n" stx)
  (syntax-case stx ()
    [(_ expr)
     ;; (begin
     ;;   (printf "my-module-begin
     ;; #'(#%module-begin
     ;;    (+ 1 2)
     ;;    )
     #`(#%module-begin
        (define prog (quote #,(convert-expr #'expr)))
        (display prog)
        (provide prog)
        )
     ]
    ))

