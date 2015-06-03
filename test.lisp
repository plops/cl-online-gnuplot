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

(cffi:defcfun j1 :double (x :double))


(let* ((w 37)
       (h 12)
       ;; allocate a 1d array
       (a1 (make-array (* w h) :element-type '(complex double-float)))
       ;; create a 2d array for access
       (a (make-array (list h w) :element-type '(complex double-float)
   ;                   :displaced-to a1
		      )))

  ;; fill the 2d array with a sinosoidal grating
  (dotimes (i w)
    (dotimes (j h)
      (setf (aref a j i) (complex (let ((r (sqrt (+ (expt (- (/ i w) .5d0) 2)
						    (expt (- (/ j h) .5) 2)))))
				    (if (< (abs r) 1d-9)
					1d0
					(/ (j1 r) r)))))))

  ;; call fftw
  (defparameter *bla* (fftw:ft a))

  ;; print out each element of the array. scale data to lie within 0..9
  (progn
    (terpri)
    (destructuring-bind (h w) (array-dimensions *bla*)
      (dotimes (j h)
        (dotimes (i w)
          (format t "~1,'0d" (floor (abs (aref *bla* j i)) (/ (* h w) 9))))
        (terpri)))))


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
