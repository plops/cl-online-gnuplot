(eval-when (:execute :load-toplevel :compile-toplevel)
  (setf asdf:*central-registry*
        '(*default-pathname-defaults*
          #p "/home/martin/stage/cl-online-gnuplot/"))
  (asdf:load-system "cl-online-gnuplot"))

(defpackage :gnuplot-test
  (:use :cl :cl-online-gnuplot))
(in-package :gnuplot-test)

(dotimes (j 12)
  (let* ((n 27)
	 (l (loop for i below n collect (list i (exp (- (/ (expt (/ i n) 2)
						    (* (+ j 2) .05d0))))))))
    (plot l)
    (sleep .1)))

(cl-online-gnuplot::gnuplot-send (format nil "
 plot '-' matrix with image
~{~{~a ~}~%~}
e
e" '((5 4 3 1 0)
     (2 2 0 0 1)
     (0 0 0 1 0)
     (0 1 2 4 3))))

(cl-online-gnuplot::gnuplot-send (format nil "
splot '-' matrix with pm3d
~{~{~a ~}~%~}
e
e" '((5 4 3 1 0)
     (2 2 0 0 1)
     (0 0 0 1 0)
     (0 1 2 4 3))))
