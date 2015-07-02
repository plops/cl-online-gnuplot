;; gnuplot communication from matlisp
;; realtime plotting: http://stackoverflow.com/questions/9162331/high-performance-realtime-data-display
(in-package #:cl-online-gnuplot)
(defparameter *current-gnuplot-process* nil)
(defun open-gnuplot-stream (&key (gnuplot-binary
				  (pathname "/usr/bin/gnuplot"))
				 (display ":0"))
  (setf *current-gnuplot-process* (sb-ext:run-program
				   gnuplot-binary nil :environment `(,(format nil "DISPLAY=~a" display)) :input :stream :wait nil :output t))
  *current-gnuplot-process*)

#+nil
(open-gnuplot-stream)

(defun close-gnuplot-stream ()
  (when *current-gnuplot-process*
    (gnuplot-send "quit~%")
    (setf *current-gnuplot-process* nil)))

#+nil
(close-gnuplot-stream)
#+nil
(setf *current-gnuplot-process* nil)

(defun gnuplot-send (str &rest args)
  (unless *current-gnuplot-process*
    (setf *current-gnuplot-process* (open-gnuplot-stream)))
  (let ((stream (sb-ext:process-input *current-gnuplot-process*)))
    (apply #'format (append (list stream str) args))
    (finish-output stream)))


(defun plot (a &key (xrange nil) (yrange nil) (logy nil))
  "plot a list of (x y) positions ((1 32.3) (2 93.3) .. )"
  (with-open-file (s "/dev/shm/o.dat" :direction :output :if-exists :supersede
		     :if-does-not-exist :create)
    (loop for (i j) in a do
	 (format s "~12,8f ~12,8f~%" i j)))
  (gnuplot-send (format nil "~{~a~%~} f(x) = A*exp(-(x-xc)**2/(2*(sigma**2)));
 A=1; sigma=.5; xc=.1;
 set fit logfile '/dev/shm/fit.log' quiet;
 fit f(x) '/dev/shm/o.dat' u 1:2 via A,sigma,xc;
 set grid;
 plot '/dev/shm/o.dat' u 1:2 w lp, f(x)~%"
			(list (if xrange
				    (format nil "set xrange [~a:~a];" (first xrange) (second xrange))
				    (format nil "set xrange [*:*];"))
				(if yrange
				    (format nil "set yrange [~a:~a];" (first yrange) (second yrange))
				    (format nil "set yrange [*:*];"))
				(if logy
				    (format nil "set logscale y;")
				    (format nil "unset logscale y;"))))))

(defun multi-plot (a &key (xrange nil) (yrange nil) (logy nil))
    "plot multiple lines from a list of (x y0 y1 y2 y3 .. ) positions ((1 32.3 12.3 3.2) (2 93.3 12.4 3.2) .. )"
  (with-open-file (s "/dev/shm/o.dat" :direction :output :if-exists :supersede
		     :if-does-not-exist :create)
    (loop for e in a do
	 (format s "~{~14,8f ~}~%" e)))

  (cl-online-gnuplot::gnuplot-send
   (format nil "~{~a~%~}
 set grid;
 unset key;
 plot ~{~a ~}~%"
	   (list (if xrange
		     (format nil "set xrange [~a:~a];" (first xrange) (second xrange))
		     (format nil "set xrange [*:*];"))
		 (if yrange
		     (format nil "set yrange [~a:~a];" (first yrange) (second yrange))
		     (format nil "set yrange [*:*];"))
		 (if logy
		     (format nil "set logscale y;")
		     (format nil "unset logscale y;")))
	   (let ((n (length (elt a 0))))
	     (loop for i from 1 below n collect
		  (if (= i (- n 1))
		      (format nil "'/dev/shm/o.dat' u 1:~a w l" (1+ i))
		      (format nil "'/dev/shm/o.dat' u 1:~a w l," (1+ i))))))))

(defun multi-x-plot (a &key (xrange nil) (yrange nil) (logy nil))
  "plot multiple lines from a list of (((ax0 ay0) (ax1 ay1) .. ) ((bx0 by0) (bx1 by1) .. ))"
  (loop for i below (length a) do
       (with-open-file (s (format nil "/dev/shm/o~a.dat" i) :direction :output :if-exists :supersede
			  :if-does-not-exist :create)
	 (loop for (x y) in (elt a i) do
	      (format s "~{~14,8f ~}~%" (list x y)))))

  (cl-online-gnuplot::gnuplot-send
   (format nil "~{~a~%~}
 set grid;
 unset key;
 plot ~{~a ~}~%"
	   (list (if xrange
		     (format nil "set xrange [~a:~a];" (first xrange) (second xrange))
		     (format nil "set xrange [*:*];"))
		 (if yrange
		     (format nil "set yrange [~a:~a];" (first yrange) (second yrange))
		     (format nil "set yrange [*:*];"))
		 (if logy
		     (format nil "set logscale y;")
		     (format nil "unset logscale y;")))
	   (loop for i below (length a) collect
		(format nil "'/dev/shm/o~d.dat' u 1:2 w lp~c" i (if (= i (1- (length a))) #\Space #\, ))
		    ))))

#+nil
(ql:quickload :quickproject)
#+nil
(quickproject:make-project "/dev/shm/cl-online-gnuplot" :author "Martin Kielhorn" :license "GPLv3" :name "cl-online-gnuplot")
