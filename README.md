This package runs a gnuplot instance and allows to send commands over a stream.
The following example displays an animation of a Gaussian bell curve getting wider:

```common-lisp
(dotimes (j 12)
  (let* ((n 27)
	 (l (loop for i below n collect (exp (- (/ (expt (/ i n) 2)
						   (* (+ j 2) .05d0)))))))
    (plot l)
    (sleep .1)))
```