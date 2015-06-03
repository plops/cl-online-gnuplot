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

(cffi:defcfun j0 :double (x :double))


(let* ((w 128)
       (h 128)
       ;; allocate a 1d array
       (a1 (make-array (* w h) :element-type '(complex double-float)))
       ;; create a 2d array for access
       (a (make-array (list h w) :element-type '(complex double-float)
   ;                   :displaced-to a1
		      )))

  (dotimes (i w)
    (dotimes (j h)
      (setf (aref a j i) (* (if (= 1 (mod (+ i j) 2))
				-1
				1)
			    (complex (let ((r (* 200 (sqrt (+ (expt (- (/ i w) .5d0) 2)
							    (expt (- (/ j h) .5) 2))))))
				     (if (< (abs r) 1d-9)
					 1d0
					 (/ (j0 r) r))))))))

  ;; call fftw
  (defparameter *bla* (fftw:ft a)
    )

  (plot-image))


(defun plot-image () (loop for b from .1 upto 2.3 by .1 do
		    (cl-online-gnuplot::gnuplot-send (format nil "
set zrange [0:500]
 plot '-' matrix with image
~{~{~a ~}~%~}
e
e" (destructuring-bind (h w) (array-dimensions *bla*)
     (loop for j below h collect
	  (loop for i below w collect
	       (abs (aref *bla* j i)))))))))

(cl-online-gnuplot::gnuplot-send (format nil "
splot '-' matrix with pm3d
~{~{~a ~}~%~}
e
e" (loop for i below 64 collect
	(loop for j below 64 collect
	     (- (sqrt (+ (expt (- i 32) 2) (expt (- j 32) 2))))))))
