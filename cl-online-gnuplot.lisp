;; gnuplot communication from matlisp
;; realtime plotting: http://stackoverflow.com/questions/9162331/high-performance-realtime-data-display
(in-package #:cl-online-gnuplot)
(defparameter *current-gnuplot-process* nil)
(defun open-gnuplot-stream (&key (gnuplot-binary
				  (pathname "/usr/bin/gnuplot")))
  (setf *current-gnuplot-process* (sb-ext:run-program
				   gnuplot-binary nil :input :stream :wait nil :output t))
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
  (with-open-file (s "/dev/shm/o.dat" :direction :output :if-exists :supersede
		     :if-does-not-exist :create)
    (loop for (i j) in a do
	 (format s "~12,8f ~12,8f~%" i j)))
  (gnuplot-send (format nil "~{~a~%~} plot '/dev/shm/o.dat' u 1:2 w lp~%"
			(list (if xrange
				    (format nil "set xrange [~a:~a];" (first xrange) (second xrange))
				    (format nil "set xrange [*:*];"))
				(if yrange
				    (format nil "set yrange [~a:~a];" (first yrange) (second yrange))
				    (format nil "set yrange [*:*];"))
				(if logy
				    (format nil "set logscale y;")
				    (format nil "unset logscale y;"))))))

#+nil
(ql:quickload :quickproject)
#+nil
(quickproject:make-project "/dev/shm/cl-online-gnuplot" :author "Martin Kielhorn" :license "GPLv3" :name "cl-online-gnuplot")
