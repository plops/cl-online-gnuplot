(ql:quickload :cl-online-gnuplot)
(ql:quickload :fftw)

(defpackage :gnuplot-test
  (:use :cl :cl-online-gnuplot))
(in-package :gnuplot-test)

(dotimes (j 12)
  (let* ((n 27)
	 (l (loop for i below n collect (list i (exp (- (/ (expt (/ i n) 2)
						    (* (+ j 2) .05d0))))))))
    (plot l)
    (sleep .1)))

(loop for b from .1 upto 2.3 by .1 do
     (cl-online-gnuplot::gnuplot-send (format nil "
set zrange [0:500]
 plot '-' matrix with image
~{~{~a ~}~%~}
e
e" (loop for i below 256 collect
	(loop for j below 256 collect
	     (floor (sqrt (+ (expt (- i 128) 2) (expt (* b (- j 128)) 2))))
	     )))))

(cl-online-gnuplot::gnuplot-send (format nil "
splot '-' matrix with pm3d
~{~{~a ~}~%~}
e
e" (loop for i below 64 collect
	(loop for j below 64 collect
	     (- (sqrt (+ (expt (- i 32) 2) (expt (- j 32) 2))))))))
