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


(defun plot (a)
  (with-open-file (s "/dev/shm/o.dat" :direction :output :if-exists :supersede
		     :if-does-not-exist :create)
    (loop for i below (length a) do
	 (format s "~12,8f ~12,8f~%" i (elt a i))))
  (gnuplot-send "set yrange [0:1];  set xrange [*:*]; plot '/dev/shm/o.dat' u 1:2 w lp~%"))

#+nil
(ql:quickload :quickproject)
#+nil
(quickproject:make-project "/dev/shm/cl-online-gnuplot" :author "Martin Kielhorn" :license "GPLv3" :name "cl-online-gnuplot")
