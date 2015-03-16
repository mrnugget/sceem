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

;; recursive calls
(define fact (lambda (n) (if (eq? n 1) 1 (* n (fact (- n 1))))))
(fact 100)

;; if expression
(define test-eq (lambda (a b) (if (eq? a b) (println "true") (println "false"))))
(define iter (lambda (start end) (if (eq? start end) (println "lol") (iter (+ start 1) end))))

;; nested function definition
(define iter-times (lambda (times) (define iter (lambda (start end) (if (eq? start end) (println start) (iter (+ start 1) end)))) (iter 0 times)))

;; begin
(begin (+ 5 5) (+ 10 10))

;; begin in procedure
(define run-times (lambda (f times) (define iter (lambda (current end) (if (eq? current end) "done" (begin (f) (iter (+ current 1) end))))) (iter 0 times)))
(run-times (lambda () (println "foobar")) 10)
