# sceem - A small Lisp/Scheme interpreter written in Ruby

![Screenshot of sceem REPL](http://s3.thorstenball.com/sceem_screenshot.png "Sceem")

This is a small Scheme interpreter written in Ruby for the fun of it. This is
recreational programming.

There are no goals for sceem. This is just programming for the sake of it.

sceem is heavily inspired by the [Metacircular Evaluator in
SICP](https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-26.html#%_sec_4.1) and Peter
Norvig's [lispy](http://norvig.com/lispy.html).

sceem is already quite powerful. At the moment sceem has a few **primitive
procedures** and support **definitions**, **if expressions**, **quotating** and
**lambdas**.

## Tests

Running the tests (or any other Scheme file) is easy:

```bash
./sceem.rb tests.scm
```

## License

Do whatever you want with this!
