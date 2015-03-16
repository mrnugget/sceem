(+ 5 5)
(- 10 5)
(* 5 5 (+ 5 (/ 20 2)))
(/ 10 2)

(println "testing")

((lambda (x) (* x x)) 5)

(define square (lambda (x) (* x x)))
(square 5)

(define make-adder (lambda (amount) (lambda (x) (+ x amount))))
(define add-two (make-adder 2))
(add-two 2)

(define print-twice (lambda (msg) (println msg) (println msg)))
(print-twice "Thorsten")

(define run-once (lambda (f) (lambda (x) (f x))))
((run-once square) 5)

(define run-twice (lambda (f) (lambda (x) (f (f x)))))
((run-twice square) 5)

(define fact (lambda (n) (if (eq? n 1) 1 (* n (fact (- n 1))))))
(fact 100)
